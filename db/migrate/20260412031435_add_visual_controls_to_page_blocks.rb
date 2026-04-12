class AddVisualControlsToPageBlocks < ActiveRecord::Migration[8.0]
  def change
    add_column :page_blocks, :column_span, :integer, null: false, default: 12
    add_column :page_blocks, :text_align, :string, null: false, default: "left"
    add_column :page_blocks, :background_style, :string, null: false, default: "card"
    add_column :page_blocks, :section_spacing, :string, null: false, default: "md"
  end
end
