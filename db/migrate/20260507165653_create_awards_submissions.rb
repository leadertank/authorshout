class CreateAwardsSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :awards_submissions do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :author_email, null: false
      t.string :book_title, null: false
      t.string :book_url, null: false
      t.string :website_url
      t.string :x_url
      t.string :facebook_url
      t.string :instagram_url
      t.string :public_token, null: false
      t.integer :payment_status, null: false, default: 0
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.datetime :paid_at
      t.datetime :support_emailed_at

      t.timestamps
    end

    add_index :awards_submissions, :public_token, unique: true
    add_index :awards_submissions, :payment_status
    add_index :awards_submissions, :created_at
    add_index :awards_submissions, :stripe_checkout_session_id
  end
end
