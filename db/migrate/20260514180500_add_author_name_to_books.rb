class AddAuthorNameToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :author_name, :string
  end
end
