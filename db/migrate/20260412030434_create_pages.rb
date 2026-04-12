class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :status, null: false, default: 0
      t.text :summary
      t.string :layout_template, null: false, default: "standard"
      t.datetime :published_at

      t.timestamps
    end

    add_index :pages, :slug, unique: true
    add_index :pages, :status
  end
end
