class SupportRequestsController < ApplicationController
  def new
    @support_message = SupportMessage.new(
      name: current_user&.display_name,
      email: current_user&.email,
      human_verification: "0"
    )
  end

  def create
    @support_message = SupportMessage.new(support_message_params)

    if @support_message.valid?
      SupportMailer.contact_request(@support_message).deliver_now
      redirect_to new_support_path, notice: "Your message was sent to support."
    else
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => error
    Rails.logger.error("Support request email failed: #{error.class}: #{error.message}")
    flash.now[:alert] = "We could not send your message right now. Please try again shortly."
    render :new, status: :unprocessable_entity
  end

  private

  def support_message_params
    params.require(:support_message).permit(:name, :email, :message, :human_verification, :organization_name)
  end
end
