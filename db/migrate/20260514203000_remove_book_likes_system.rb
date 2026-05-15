class RemoveBookLikesSystem < ActiveRecord::Migration[8.0]
  def change
    drop_table :book_likes do |t|
      t.integer :book_id, null: false
      t.integer :user_id
      t.string :visitor_token
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index [ :book_id, :user_id ], unique: true, where: "user_id IS NOT NULL"
      t.index [ :book_id, :visitor_token ], unique: true, where: "visitor_token IS NOT NULL"
      t.index [ :book_id ]
      t.index [ :user_id ]
    end

    remove_column :books, :likes_count, :integer, default: 0, null: false
  end
end
