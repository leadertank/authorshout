module Admin
	class FormsController < BaseController
		before_action :set_form, only: [:show, :edit, :update, :destroy]

		def index
			@forms = Form.includes(:form_fields, :form_submissions).order(updated_at: :desc)
			@forms = @forms.search_query(params[:query]) if params[:query].present?
			@forms = @forms.where(status: params[:state]) if params[:state].present?
		end

		def show
			@recent_submissions = @form.form_submissions.limit(10)
		end

		def new
			@form = Form.new(status: :draft, payment_mode: :free, payment_provider: "paypal", currency: "USD", submit_button_text: "Submit")
			@form.form_fields.build(field_type: "text", label: "Full Name", identifier: "full_name", position: 1)
			@form.form_fields.build(field_type: "email", label: "Email", identifier: "email", position: 2, required: true)
		end

		def edit
			@form.form_fields.build(field_type: "text", position: next_field_position) if @form.form_fields.empty?
		end

		def create
			@form = Form.new(form_params)

			if @form.save
				redirect_to admin_form_path(@form), notice: "Form created successfully."
			else
				render :new, status: :unprocessable_entity
			end
		end

		def update
			if @form.update(form_params)
				redirect_to admin_form_path(@form), notice: "Form updated successfully."
			else
				render :edit, status: :unprocessable_entity
			end
		end

		def destroy
			@form.destroy
			redirect_to admin_forms_path, notice: "Form deleted successfully."
		end

		private

		def set_form
			@form = Form.includes(:form_fields, :form_submissions).find_by!(slug: params[:id])
		end

		def next_field_position
			@form.form_fields.maximum(:position).to_i + 1
		end

		def form_params
			params.require(:form).permit(
				:title,
				:slug,
				:status,
				:description,
				:success_message,
				:submit_button_text,
				:payment_mode,
				:payment_provider,
				:amount_cents,
				:currency,
				:billing_interval,
				:provider_plan_id,
				:builder_json,
				form_fields_attributes: [
					:id,
					:label,
					:identifier,
					:field_type,
					:required,
					:placeholder,
					:help_text,
					:options_text,
					:position,
					:width,
					:_destroy
				]
			)
		end
	end
end