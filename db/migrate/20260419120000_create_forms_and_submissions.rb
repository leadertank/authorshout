class CreateFormsAndSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :forms do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :status, null: false, default: 0
      t.text :description
      t.text :success_message
      t.string :submit_button_text, null: false, default: "Submit"
      t.integer :payment_mode, null: false, default: 0
      t.string :payment_provider, null: false, default: "paypal"
      t.integer :amount_cents, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.string :billing_interval
      t.string :provider_plan_id
      t.text :builder_json

      t.timestamps
    end
    add_index :forms, :slug, unique: true
    add_index :forms, :status

    create_table :form_fields do |t|
      t.references :form, null: false, foreign_key: true
      t.string :label, null: false
      t.string :identifier, null: false
      t.string :field_type, null: false, default: "text"
      t.boolean :required, null: false, default: false
      t.string :placeholder
      t.string :help_text
      t.text :options_text
      t.integer :position, null: false, default: 0
      t.integer :width, null: false, default: 12

      t.timestamps
    end
    add_index :form_fields, [:form_id, :identifier], unique: true
    add_index :form_fields, [:form_id, :position]

    create_table :form_submissions do |t|
      t.references :form, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :public_token, null: false
      t.integer :status, null: false, default: 0
      t.integer :payment_status, null: false, default: 0
      t.string :payment_provider
      t.string :payment_reference
      t.string :provider_customer_reference
      t.string :submitter_email
      t.text :payload_json
      t.datetime :submitted_at
      t.datetime :paid_at

      t.timestamps
    end
    add_index :form_submissions, :public_token, unique: true
    add_index :form_submissions, [:form_id, :created_at]
    add_index :form_submissions, [:form_id, :payment_status]

    create_table :form_payment_events do |t|
      t.references :form_submission, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :event_type, null: false
      t.string :external_id
      t.string :status
      t.text :payload_json
      t.datetime :processed_at, null: false

      t.timestamps
    end
    add_index :form_payment_events, [:provider, :external_id]
  end
end