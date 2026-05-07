require "test_helper"

class SupportRequestsTest < ActionDispatch::IntegrationTest
  test "renders support form" do
    get new_support_path

    assert_response :success
    assert_match "Contact Support", response.body
  end

  test "submits support request and sends email" do
    ActionMailer::Base.deliveries.clear

    assert_emails 1 do
      post support_path, params: {
        support_message: {
          name: "Ada Lovelace",
          email: "ada@example.com",
          message: "I need help with my profile."
        }
      }
    end

    assert_redirected_to new_support_path
    follow_redirect!
    assert_match "Your message was sent to support", response.body

    mail = ActionMailer::Base.deliveries.last
    assert_equal ["support@authorshout.com"], mail.to
    assert_equal ["ada@example.com"], mail.reply_to
    text_body = mail.text_part ? mail.text_part.body.to_s : mail.body.to_s
    assert_match "I need help with my profile.", text_body
  end

  test "invalid support request re-renders with errors" do
    post support_path, params: {
      support_message: {
        name: "",
        email: "not-an-email",
        message: ""
      }
    }

    assert_response :unprocessable_entity
    assert_match "Please fix these issues", response.body
  end
end
