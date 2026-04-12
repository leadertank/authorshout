class AddRowLayoutFieldsToPageBlocks < ActiveRecord::Migration[8.0]
  def change
    add_column :page_blocks, :row_number, :integer, null: false, default: 1
    add_column :page_blocks, :column_slot, :integer, null: false, default: 1
    add_column :page_blocks, :row_columns, :integer, null: false, default: 1

    add_index :page_blocks, [:page_id, :row_number, :column_slot, :position], name: "index_page_blocks_on_layout_position"
  end
end