class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.references :profile, null: false, foreign_key: true, index: { unique: true }
      t.string :title, null: false
      t.string :purchase_url, null: false
      t.integer :likes_count, null: false, default: 0

      t.timestamps
    end
  end
end
