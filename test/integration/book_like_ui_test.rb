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

  test "profile route uses first and last name slug" do
    assert_equal "/profiles/ada-lovelace", profile_path(profiles(:one))

    get "/profiles/ada-lovelace"
    assert_response :success
  end

  test "removing an existing book persists across profile and home pages" do
    sign_in users(:one)

    book = books(:one)

    patch my_profile_path, params: {
      profile: {
        books_attributes: {
          "0" => {
            id: book.id,
            _destroy: "1"
          }
        }
      }
    }

    assert_redirected_to profile_path(profiles(:one))
    assert_not Book.exists?(book.id)

    get profile_path(profiles(:one))
    assert_response :success
    assert_no_match "Analytical Engine Stories", response.body

    get root_path
    assert_response :success
    assert_no_match "Analytical Engine Stories", response.body
  end

  test "signed in member sees current media previews on edit profile" do
    sign_in users(:one)

    get edit_my_profile_path

    assert_response :success
    assert_match "Author Details", response.body
    assert_match "Books From This Author", response.body
    assert_match "Current Profile Preview", response.body
    assert_match "No profile image yet", response.body
    assert_match "Current book cover", response.body
    assert_match "View Public Profile", response.body
  end
end
