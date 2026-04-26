class CreatePageBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :page_blocks do |t|
      t.references :page, null: false, foreign_key: true
      t.string :kind, null: false, default: "text"
      t.integer :position, null: false, default: 0
      t.string :heading
      t.string :subheading
      t.text :body
      t.string :button_text
      t.string :button_url
      t.string :media_url
      t.string :theme

      t.timestamps
    end

    add_index :page_blocks, [ :page_id, :position ]
  end
end
