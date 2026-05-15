class CreateManualAwards < ActiveRecord::Migration[8.0]
  def change
    create_table :manual_awards do |t|
      t.string :title, null: false
      t.string :author_name, null: false
      t.string :book_url
      t.string :cover_image_url
      t.boolean :editor_choice, null: false, default: false
      t.boolean :top_pick, null: false, default: false
      t.boolean :recommended_read, null: false, default: false
      t.boolean :honorable_mention, null: false, default: false
      t.integer :primary_page

      t.timestamps
    end

    add_index :manual_awards, :editor_choice
    add_index :manual_awards, :top_pick
    add_index :manual_awards, :recommended_read
    add_index :manual_awards, :honorable_mention
    add_index :manual_awards, :primary_page
  end
end
