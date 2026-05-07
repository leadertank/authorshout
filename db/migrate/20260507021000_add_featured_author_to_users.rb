class AddFeaturedAuthorToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :featured_author, :boolean, default: false, null: false
    add_index :users, :featured_author
  end
end