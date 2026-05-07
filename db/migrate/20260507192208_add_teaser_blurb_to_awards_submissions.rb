class AddTeaserBlurbToAwardsSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :awards_submissions, :teaser_blurb, :string
  end
end
