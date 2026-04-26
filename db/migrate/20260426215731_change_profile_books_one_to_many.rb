class ChangeProfileBooksOneToMany < ActiveRecord::Migration[8.0]
  def change
    # Add featured column to books table
    add_column :books, :featured, :boolean, default: false, null: false
    add_index :books, :featured

    # Remove the unique index on profile_id to allow multiple books per profile
    remove_index :books, column: :profile_id, unique: true
    add_index :books, :profile_id
  end
end
