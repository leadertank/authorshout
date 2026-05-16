class User < ApplicationRecord
  attr_accessor :human_verification

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
      :recoverable, :rememberable, :validatable, :masqueradable

  has_one :profile, dependent: :destroy

  pay_customer default_payment_processor: :stripe

  validates :human_verification, acceptance: {
    accept: "1",
    message: "must be checked before creating an account"
  }, on: :create

  after_create :create_default_profile
  after_commit :enqueue_welcome_email, on: :create
  after_commit :enqueue_admin_signup_alert, on: :create

  scope :admins_first, -> { order(admin: :desc, created_at: :asc) }

  # Guard against stale app processes that haven't reloaded schema yet.
  # This keeps author-directory rendering safe even if featured_author
  # method generation has not been refreshed.
  def featured_author?
    return false unless has_attribute?(:featured_author)

    ActiveModel::Type::Boolean.new.cast(self[:featured_author])
  end

  def display_name
    full_name.presence || email.to_s.split("@").first.titleize
  end

  def full_name
    [ first_name, last_name ].join(" ").squish
  end

  def paid_member?
    return true if admin?
    return true if manual_paid?

    pay_subscriptions.active.exists?
  end

  def verified_featured_author?
    return true if paid_member?

    featured_author?
  end

  def free_member?
    !paid_member?
  end

  def book_limit
    paid_member? ? nil : 1
  end

  def plan_label
    paid_member? ? "PAID" : "FREE"
  end

  private

  def create_default_profile
    create_profile!
  end

  def enqueue_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end

  def enqueue_admin_signup_alert
    AdminNotifierMailer.new_member_signup(self).deliver_now
  rescue StandardError => error
    Rails.logger.error("Admin signup alert failed for user ##{id}: #{error.class}: #{error.message}")
  end
end
