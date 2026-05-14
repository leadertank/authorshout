class MakeBookProfileOptionalAndAddAdminSubmitted < ActiveRecord::Migration[7.0]
  def change
    change_column_null :books, :profile_id, true
    add_column :books, :admin_submitted, :boolean, default: false, null: false
  end
end
