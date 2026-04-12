admin = User.find_or_initialize_by(email: "admin@authorshout.local")
admin.password = "Password123!"
admin.password_confirmation = "Password123!"
admin.admin = true
admin.human_verification = "1"
admin.save!

puts "Admin account ready: admin@authorshout.local / Password123!"
