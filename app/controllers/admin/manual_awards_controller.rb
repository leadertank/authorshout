module Admin
  class ManualAwardsController < BaseController
    before_action :set_manual_award, only: [ :edit, :update, :destroy ]

    def index
      @manual_awards = ManualAward.recent_first
    end

    def new
      @manual_award = ManualAward.new
    end

    def create
      @manual_award = ManualAward.new(manual_award_params)
      if @manual_award.save
        redirect_to admin_manual_awards_path, notice: "Manual award entry was successfully added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @manual_award.update(manual_award_params)
        redirect_to admin_manual_awards_path, notice: "Manual award entry was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @manual_award.destroy
      redirect_to admin_manual_awards_path, notice: "Manual award entry was successfully deleted."
    end

    private

    def set_manual_award
      @manual_award = ManualAward.find(params[:id])
    end

    def manual_award_params
      params.require(:manual_award).permit(
        :title,
        :author_name,
        :book_url,
        :cover_image,
        :cover_image_url,
        :editor_choice,
        :top_pick,
        :recommended_read,
        :honorable_mention,
        :primary_page
      )
    end
  end
end
