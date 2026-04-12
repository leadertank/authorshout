class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.text :bio
      t.string :website
      t.string :x_url
      t.string :facebook_url
      t.string :instagram_url
      t.string :threads_url
      t.string :bluesky_url
      t.string :youtube_url

      t.timestamps
    end
  end
end
