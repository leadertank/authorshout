# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_04_19_120000) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "book_likes", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "user_id"
    t.string "visitor_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "user_id"], name: "index_book_likes_on_book_id_and_user_id", unique: true, where: "user_id IS NOT NULL"
    t.index ["book_id", "visitor_token"], name: "index_book_likes_on_book_id_and_visitor_token", unique: true, where: "visitor_token IS NOT NULL"
    t.index ["book_id"], name: "index_book_likes_on_book_id"
    t.index ["user_id"], name: "index_book_likes_on_user_id"
  end

  create_table "books", force: :cascade do |t|
    t.integer "profile_id", null: false
    t.string "title", null: false
    t.string "purchase_url", null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_image_url"
    t.index ["profile_id"], name: "index_books_on_profile_id", unique: true
  end

  create_table "form_fields", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "label", null: false
    t.string "identifier", null: false
    t.string "field_type", default: "text", null: false
    t.boolean "required", default: false, null: false
    t.string "placeholder"
    t.string "help_text"
    t.text "options_text"
    t.integer "position", default: 0, null: false
    t.integer "width", default: 12, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id", "identifier"], name: "index_form_fields_on_form_id_and_identifier", unique: true
    t.index ["form_id", "position"], name: "index_form_fields_on_form_id_and_position"
    t.index ["form_id"], name: "index_form_fields_on_form_id"
  end

  create_table "form_payment_events", force: :cascade do |t|
    t.integer "form_submission_id", null: false
    t.string "provider", null: false
    t.string "event_type", null: false
    t.string "external_id"
    t.string "status"
    t.text "payload_json"
    t.datetime "processed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_submission_id"], name: "index_form_payment_events_on_form_submission_id"
    t.index ["provider", "external_id"], name: "index_form_payment_events_on_provider_and_external_id"
  end

  create_table "form_submissions", force: :cascade do |t|
    t.integer "form_id", null: false
    t.integer "user_id"
    t.string "public_token", null: false
    t.integer "status", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.string "payment_provider"
    t.string "payment_reference"
    t.string "provider_customer_reference"
    t.string "submitter_email"
    t.text "payload_json"
    t.datetime "submitted_at"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id", "created_at"], name: "index_form_submissions_on_form_id_and_created_at"
    t.index ["form_id", "payment_status"], name: "index_form_submissions_on_form_id_and_payment_status"
    t.index ["form_id"], name: "index_form_submissions_on_form_id"
    t.index ["public_token"], name: "index_form_submissions_on_public_token", unique: true
    t.index ["user_id"], name: "index_form_submissions_on_user_id"
  end

  create_table "forms", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.text "description"
    t.text "success_message"
    t.string "submit_button_text", default: "Submit", null: false
    t.integer "payment_mode", default: 0, null: false
    t.string "payment_provider", default: "paypal", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "currency", default: "USD", null: false
    t.string "billing_interval"
    t.string "provider_plan_id"
    t.text "builder_json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_forms_on_slug", unique: true
    t.index ["status"], name: "index_forms_on_status"
  end

  create_table "page_blocks", force: :cascade do |t|
    t.integer "page_id", null: false
    t.string "kind", default: "text", null: false
    t.integer "position", default: 0, null: false
    t.string "heading"
    t.string "subheading"
    t.text "body"
    t.string "button_text"
    t.string "button_url"
    t.string "media_url"
    t.string "theme"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "column_span", default: 12, null: false
    t.string "text_align", default: "left", null: false
    t.string "background_style", default: "card", null: false
    t.string "section_spacing", default: "md", null: false
    t.integer "row_number", default: 1, null: false
    t.integer "column_slot", default: 1, null: false
    t.integer "row_columns", default: 1, null: false
    t.index ["page_id", "position"], name: "index_page_blocks_on_page_id_and_position"
    t.index ["page_id", "row_number", "column_slot", "position"], name: "index_page_blocks_on_layout_position"
    t.index ["page_id"], name: "index_page_blocks_on_page_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.text "summary"
    t.string "layout_template", default: "standard", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "builder_json"
    t.text "builder_html"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
    t.index ["status"], name: "index_pages_on_status"
  end

  create_table "post_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_post_categories_on_name", unique: true
    t.index ["slug"], name: "index_post_categories_on_slug", unique: true
  end

  create_table "post_taggings", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "post_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "post_tag_id"], name: "index_post_taggings_on_post_id_and_post_tag_id", unique: true
    t.index ["post_id"], name: "index_post_taggings_on_post_id"
    t.index ["post_tag_id"], name: "index_post_taggings_on_post_tag_id"
  end

  create_table "post_tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_post_tags_on_name", unique: true
    t.index ["slug"], name: "index_post_tags_on_slug", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.text "excerpt"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "post_category_id"
    t.index ["post_category_id"], name: "index_posts_on_post_category_id"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["status"], name: "index_posts_on_status"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "bio"
    t.string "website"
    t.string "x_url"
    t.string "facebook_url"
    t.string "instagram_url"
    t.string "threads_url"
    t.string "bluesky_url"
    t.string "youtube_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_url"
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "book_likes", "books"
  add_foreign_key "book_likes", "users"
  add_foreign_key "books", "profiles"
  add_foreign_key "form_fields", "forms"
  add_foreign_key "form_payment_events", "form_submissions"
  add_foreign_key "form_submissions", "forms"
  add_foreign_key "form_submissions", "users"
  add_foreign_key "page_blocks", "pages"
  add_foreign_key "post_taggings", "post_tags"
  add_foreign_key "post_taggings", "posts"
  add_foreign_key "posts", "post_categories"
  add_foreign_key "profiles", "users"
end
