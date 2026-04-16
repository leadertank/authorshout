class AddPostTaxonomyAndAdminFilters < ActiveRecord::Migration[8.0]
  def change
    create_table :post_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    create_table :post_tags do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    create_table :post_taggings do |t|
      t.references :post, null: false, foreign_key: true
      t.references :post_tag, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :posts, :post_category, foreign_key: true

    add_index :post_categories, :name, unique: true
    add_index :post_categories, :slug, unique: true
    add_index :post_tags, :name, unique: true
    add_index :post_tags, :slug, unique: true
    add_index :post_taggings, [:post_id, :post_tag_id], unique: true
  end
end