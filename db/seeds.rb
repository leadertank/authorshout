admin_email = ENV.fetch("SEED_ADMIN_EMAIL", "admin@authorshout.local")
seed_admin_password = ENV["SEED_ADMIN_PASSWORD"].presence

if Rails.env.production? && seed_admin_password.blank?
  raise "SEED_ADMIN_PASSWORD must be set before running db:seed in production"
end

admin = User.find_or_initialize_by(email: admin_email)

password_to_set =
  if seed_admin_password.present?
    seed_admin_password
  elsif admin.new_record?
    "Password123!"
  end

if password_to_set.present?
  admin.password = password_to_set
  admin.password_confirmation = password_to_set
end

admin.admin = true
admin.first_name = "Admin"
admin.last_name = "User"
admin.human_verification = "1"
admin.save!

puts "Admin account ready: #{admin_email}"
