require "test_helper"

class UserWelcomeEmailTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "creating a user enqueues welcome and admin signup emails" do
    assert_enqueued_emails 2 do
      User.create!(
        email: "welcome-check@example.com",
        password: "Password123!",
        password_confirmation: "Password123!",
        first_name: "Welcome",
        last_name: "Tester",
        human_verification: "1"
      )
    end
  end
end
