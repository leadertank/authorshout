Pay::Webhooks.configure do |events|
  extract_event_object = lambda { |event|
    data = event.respond_to?(:data) ? event.data : nil
    return data.object if data.respond_to?(:object)

    return nil unless data.respond_to?(:to_h)

    hash = data.to_h
    hash["object"] || hash[:object]
  }

  extract_metadata_token = lambda { |event|
    object = extract_event_object.call(event)
    return nil if object.nil?

    metadata = if object.respond_to?(:metadata)
      object.metadata
    elsif object.respond_to?(:to_h)
      hash = object.to_h
      hash["metadata"] || hash[:metadata]
    end

    return nil if metadata.nil?

    if metadata.respond_to?(:[])
      metadata["awards_submission_token"] || metadata[:awards_submission_token]
    end
  }

  notify_awards_submission_if_needed = lambda { |event|
    begin
      token = extract_metadata_token.call(event)
      return if token.blank?

      submission = AwardsSubmission.find_by(public_token: token)
      return if submission.blank? || submission.support_emailed_at.present?

      submission.update!(payment_status: :paid, paid_at: submission.paid_at || Time.current)
      AwardsSubmissionMailer.entry_received(submission).deliver_now
      submission.update!(support_emailed_at: Time.current)
    rescue StandardError => error
      Rails.logger.error("Awards submission support notification failed for event #{event&.id}: #{error.class}: #{error.message}")
    end
  }

  notification_handler = lambda { |event|
    begin
      AdminNotifierMailer.payment_received(event).deliver_now
      Rails.logger.info("Payment support notification delivered for event #{event&.id} (#{event&.type})")

      notify_awards_submission_if_needed.call(event)
    rescue StandardError => error
      Rails.logger.error("Payment support notification failed for event #{event&.id}: #{error.class}: #{error.message}")

      begin
        AdminNotifierMailer.payment_received(event).deliver_later
        Rails.logger.info("Payment support notification queued for retry for event #{event&.id} (#{event&.type})")

        notify_awards_submission_if_needed.call(event)
      rescue StandardError => queue_error
        Rails.logger.error("Payment support notification retry enqueue failed for event #{event&.id}: #{queue_error.class}: #{queue_error.message}")
      end
    end
  }

  events.subscribe "stripe.charge.succeeded", notification_handler
  events.subscribe "stripe.payment_intent.succeeded", notification_handler
  events.subscribe "stripe.checkout.session.completed", notification_handler
  events.subscribe "stripe.invoice.payment_succeeded", notification_handler
end
