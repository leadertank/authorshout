module ApplicationHelper
  UNLAYER_ALLOWED_TAGS = %w[
    a abbr article b blockquote br center code col colgroup dd div dl dt em footer h1 h2 h3 h4 h5 h6
    header hr i img li ol p section small span strong style sub sup table tbody td tfoot th thead tr u ul
  ].freeze

  UNLAYER_ALLOWED_ATTRIBUTES = %w[
    align alt bgcolor border cellpadding cellspacing class colspan dir height href id rel role rowspan
    src style target title valign width
  ].freeze

  def book_liked_by_current_actor?(book)
    book.liked_by?(user: current_user, visitor_token: current_visitor_token)
  end

  def content_state_badge(record)
    content_tag(:span, record.content_state_label, class: "cms-state-badge cms-state-#{record.content_state_label.parameterize}")
  end

  def content_publish_detail(record)
    return "Draft content" if record.draft?
    return "Scheduled for #{record.published_at.strftime("%b %-d, %Y %l:%M %p")}" if record.scheduled?
    return "Live now" if record.live_now? && record.published_at.blank?

    "Live since #{record.published_at.strftime("%b %-d, %Y %l:%M %p")}"
  end

  def content_state_filter_options
    [ [ "All states", "" ], [ "Live", "live" ], [ "Scheduled", "scheduled" ], [ "Draft", "draft" ] ]
  end

  def safe_external_url(url)
    return if url.blank?

    uri = URI.parse(url)
    return url if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    nil
  rescue URI::InvalidURIError, TypeError
    nil
  end

  def sanitize_unlayer_html(html)
    sanitize(
      html,
      tags: UNLAYER_ALLOWED_TAGS,
      attributes: UNLAYER_ALLOWED_ATTRIBUTES
    )
  end
end
