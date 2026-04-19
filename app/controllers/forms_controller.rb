class FormsController < ApplicationController
	def show
		@form = Form.live.includes(:form_fields).find_by!(slug: params[:slug])
	end
end