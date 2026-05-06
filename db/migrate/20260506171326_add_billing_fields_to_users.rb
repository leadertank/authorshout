class AddBillingFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :manual_paid, :boolean, default: false, null: false
  end
end
