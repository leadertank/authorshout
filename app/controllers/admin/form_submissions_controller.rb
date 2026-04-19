require "csv"

module Admin
	class FormSubmissionsController < BaseController
		before_action :set_form
		before_action :set_submission, only: [:show]

		def index
			@submissions = @form.form_submissions.includes(:user).order(created_at: :desc)
		end

		def show; end

		def export
			headers = @form.form_fields.map(&:identifier)
			csv = CSV.generate(headers: true) do |rows|
				rows << ["submitted_at", "status", "payment_status", "submitter_email", *headers]
				@form.form_submissions.order(created_at: :asc).find_each do |submission|
					payload = submission.payload
					rows << [submission.submitted_at || submission.created_at, submission.status, submission.payment_status, submission.submitter_email, *headers.map { |key| format_csv_value(payload[key]) }]
				end
			end

			send_data csv, filename: "#{@form.slug}-submissions-#{Date.current}.csv", type: "text/csv"
		end

		private

		def set_form
			@form = Form.find_by!(slug: params[:form_id])
		end

		def set_submission
			@submission = @form.form_submissions.find(params[:id])
		end

		def format_csv_value(value)
			value.is_a?(Array) ? value.join(" | ") : value
		end
	end
end