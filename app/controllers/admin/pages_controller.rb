module Admin
  class PagesController < BaseController
    before_action :set_page, only: [:show, :edit, :update, :destroy, :preview]

    def index
      @pages = Page.order(updated_at: :desc)
    end

    def show; end

    def preview
      render "pages/show"
    end

    def new
      @page = Page.new(layout_template: "standard")
      @page.page_blocks.build(kind: "hero", position: 1, row_number: 1, column_slot: 1, row_columns: 1)
      @page.page_blocks.build(kind: "text", position: 2, row_number: 2, column_slot: 1, row_columns: 1)
    end

    def edit
      @page.page_blocks.build(kind: "text", position: next_block_position) if @page.page_blocks.empty?
    end

    def create
      @page = Page.new(page_params)

      if @page.save
        redirect_to admin_page_path(@page), notice: "Page created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @page.update(page_params)
        redirect_to admin_page_path(@page), notice: "Page updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @page.destroy
      redirect_to admin_pages_path, notice: "Page deleted successfully."
    end

    private

    def set_page
      @page = Page.find_by!(slug: params[:id])
    end

    def next_block_position
      @page.page_blocks.maximum(:position).to_i + 1
    end

    def page_params
      params.require(:page).permit(
        :title,
        :slug,
        :status,
        :summary,
        :layout_template,
        :published_at,
        :featured_image,
        :body,
        :builder_json,
        :builder_html,
        page_blocks_attributes: [
          :id,
          :kind,
          :position,
          :row_number,
          :column_slot,
          :row_columns,
          :column_span,
          :text_align,
          :background_style,
          :section_spacing,
          :heading,
          :subheading,
          :body,
          :button_text,
          :button_url,
          :media_url,
          :theme,
          :_destroy
        ]
      )
    end
  end
end
