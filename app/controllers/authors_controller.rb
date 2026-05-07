class AuthorsController < ApplicationController
  ALPHABET = ("A".."Z").to_a.freeze

  def featured
    base_scope = featured_base_scope

    @query = params[:q].to_s.strip
    @letter = normalize_letter(params[:letter])
    @featured_total = base_scope.count

    filtered = apply_search_and_letter(base_scope)
      .order(Arel.sql("LOWER(COALESCE(users.last_name, users.email)) ASC"), Arel.sql("LOWER(COALESCE(users.first_name, users.email)) ASC"))
      .distinct

    @featured_filtered = filtered.count

    @profiles = filtered
  end

  def directory
    base_scope = Profile.includes(:user).where(users: { admin: false }).references(:users)

    @query = params[:q].to_s.strip
    @letter = normalize_letter(params[:letter])
    @per_page = 24
    @directory_total = base_scope.count

    filtered = apply_search_and_letter(base_scope)
      .order(Arel.sql("LOWER(COALESCE(users.last_name, users.email)) ASC"), Arel.sql("LOWER(COALESCE(users.first_name, users.email)) ASC"))

    @total_authors = filtered.count
    @total_pages = [ (@total_authors.to_f / @per_page).ceil, 1 ].max
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @page = @total_pages if @page > @total_pages

    @profiles = filtered.offset((@page - 1) * @per_page).limit(@per_page)
  end

  private

  def normalize_letter(value)
    letter = value.to_s.strip.upcase
    ALPHABET.include?(letter) ? letter : nil
  end

  def apply_search_and_letter(scope)
    filtered = scope

    if @query.present?
      pattern = "%#{@query.downcase}%"
      filtered = filtered.where(
        "LOWER(users.first_name) LIKE :pattern OR LOWER(users.last_name) LIKE :pattern OR LOWER(users.email) LIKE :pattern",
        pattern: pattern
      )
    end

    return filtered if @letter.blank?

    filtered.where(
      "UPPER(SUBSTR(COALESCE(NULLIF(users.last_name, ''), users.email), 1, 1)) = ?",
      @letter
    )
  end

  def featured_base_scope
    now = Time.current

    Profile.includes(:user)
      .where(users: { admin: false })
      .where(
        <<~SQL.squish,
          users.featured_author = :enabled
          OR users.manual_paid = :enabled
          OR EXISTS (
            SELECT 1
            FROM pay_customers
            INNER JOIN pay_subscriptions ON pay_subscriptions.customer_id = pay_customers.id
            WHERE pay_customers.owner_type = 'User'
              AND pay_customers.owner_id = users.id
              AND pay_subscriptions.name = 'authorshout-pro'
              AND (
                (
                  pay_subscriptions.status = 'active'
                  AND (pay_subscriptions.pause_starts_at IS NULL OR pay_subscriptions.pause_starts_at > :now)
                  AND (pay_subscriptions.ends_at IS NULL OR pay_subscriptions.ends_at > :now)
                )
                OR (
                  pay_subscriptions.status IN ('on_trial', 'trialing', 'active')
                  AND pay_subscriptions.trial_ends_at > :now
                )
              )
          )
        SQL
        enabled: true,
        now: now
      )
      .references(:users)
  end
end