class FormSubmissionsController < ApplicationController
	before_action :set_form
	before_action :set_submission, only: [:complete, :cancel]

	def create
		@checkout_readiness = Payments::FormCheckoutReadiness.new(@form)
		unless @checkout_readiness.ready?
			@form_errors = @checkout_readiness.messages
			render "forms/show", status: :unprocessable_entity
			return
		end

		result = Forms::SubmissionBuilder.new(form: @form, params: form_response_params, user: current_user).call
		@submission = result.submission

		unless result.success?
			@form_errors = result.errors
			render "forms/show", status: :unprocessable_entity
			return
		end

		@submission.save!

		if @form.free?
			redirect_to form_submission_complete_path(@form.slug, @submission.public_token), notice: @form.success_message.presence || "Thanks. Your form has been submitted."
			return
		end

		gateway = Payments::Gateway.for(@form.payment_provider)
		checkout = gateway.start_checkout(
			form: @form,
			submission: @submission,
			return_url: form_submission_complete_url(@form.slug, @submission.public_token),
			cancel_url: form_submission_cancel_url(@form.slug, @submission.public_token)
		)

		@submission.update!(payment_reference: checkout.external_id)
		@submission.form_payment_events.create!(provider: @form.payment_provider, event_type: "checkout_started", external_id: checkout.external_id, status: "pending", payload: checkout.payload, processed_at: Time.current)
		redirect_to checkout.approval_url, allow_other_host: true
	rescue Payments::PaypalGateway::Error, Payments::PaypalHttpClient::Error, KeyError => error
		@submission.destroy if @submission&.persisted?
		@form_errors = [error.message.presence || "Payment setup is incomplete for this form"]
		render "forms/show", status: :unprocessable_entity
	end

	def complete
		unless @form.requires_payment?
			render :complete
			return
		end

		gateway = Payments::Gateway.for(@form.payment_provider)
		result = gateway.finalize_checkout(form: @form, submission: @submission, params: params)
		@submission.form_payment_events.create!(provider: @form.payment_provider, event_type: "checkout_completed", external_id: result.external_id, status: result.status, payload: result.payload, processed_at: Time.current)

		if result.paid
			@submission.mark_completed!(payment_reference: result.external_id, customer_reference: result.customer_reference)
		else
			@submission.update!(status: :failed, payment_status: :payment_failed, payment_reference: result.external_id)
			redirect_to form_path(@form.slug), alert: "Payment was not completed for this submission."
			return
		end
	rescue Payments::PaypalGateway::Error, Payments::PaypalHttpClient::Error, KeyError => error
		redirect_to form_path(@form.slug), alert: error.message.presence || "Unable to confirm the payment for this form submission."
	end

	def cancel
		@submission.update!(status: :canceled, payment_status: :payment_canceled)
		redirect_to form_path(@form.slug), alert: "The payment flow was canceled. Your draft submission was saved in the dashboard."
	end

	private

	def set_form
		@form = Form.includes(:form_fields).find_by!(slug: params[:slug] || params[:form_slug])
	end

	def set_submission
		@submission = @form.form_submissions.find_by!(public_token: params[:token])
	end

	def form_response_params
		params.fetch(:form_response, {}).permit!
	end
end