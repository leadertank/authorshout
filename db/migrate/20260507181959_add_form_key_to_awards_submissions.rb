class AddFormKeyToAwardsSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :awards_submissions, :form_key, :string, null: false, default: "8th-annual-author-shout-book-awards"
    add_index :awards_submissions, :form_key
  end
end
