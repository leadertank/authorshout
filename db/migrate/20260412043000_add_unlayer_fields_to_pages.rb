class AddUnlayerFieldsToPages < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :builder_json, :text
    add_column :pages, :builder_html, :text
  end
end
