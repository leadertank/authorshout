module ApplicationHelper
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
		[["All states", ""], ["Live", "live"], ["Scheduled", "scheduled"], ["Draft", "draft"]]
	end

	def form_state_filter_options
		[["All states", ""], ["Live", "published"], ["Draft", "draft"]]
	end

	def payment_mode_badge(form)
		content_tag(:span, form.payment_mode_label, class: "cms-state-badge cms-state-#{form.payment_mode.parameterize}")
	end

	def formatted_money(amount_cents, currency)
		format("%<currency>s %<amount>.2f", currency: currency, amount: amount_cents.to_i / 100.0)
	end
end
