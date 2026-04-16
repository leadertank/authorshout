require "test_helper"

class BookLikeUiTest < ActionDispatch::IntegrationTest
  test "guest sees liked state after liking a book from home" do
    post book_like_path(books(:one))
    follow_redirect!

    assert_response :success
    assert_match "Liked (2)", response.body
    assert_no_match ">Like \(2\)<", response.body
  end

  test "signed in member sees liked state for already liked book" do
    sign_in users(:one)

    get root_path

    assert_response :success
    assert_match "Liked (1)", response.body
  end

  test "profile page shows liked state for current guest visitor" do
    post book_like_path(books(:one))
    get profile_path(profiles(:one))

    assert_response :success
    assert_match "Liked (2)", response.body
  end
end