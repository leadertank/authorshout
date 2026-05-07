require "test_helper"

class SocialMediaBlitzSubmissionsTest < ActionDispatch::IntegrationTest
  test "renders social media blitz submission form" do
    get new_social_media_blitz_submission_path

    assert_response :success
    assert_match "Social Media Book Blitz (30 day blitz)", response.body
    assert_match "Submit Payment and Start Book Blitz", response.body
  end
end
