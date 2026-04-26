class CreateBookLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :book_likes do |t|
      t.references :book, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :visitor_token

      t.timestamps
    end

    add_index :book_likes, [ :book_id, :user_id ], unique: true, where: "user_id IS NOT NULL"
    add_index :book_likes, [ :book_id, :visitor_token ], unique: true, where: "visitor_token IS NOT NULL"
  end
end
