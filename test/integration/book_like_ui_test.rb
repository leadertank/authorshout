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

  test "profile route resolves slug for member with partial name" do
    user = User.create!(
      email: "support-only@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      first_name: "Support",
      last_name: nil,
      human_verification: "1"
    )

    assert_equal "/profiles/support", profile_path(user.profile)

    get "/profiles/support"
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
    assert_match "Book Covers", response.body
    assert_match "View Public Profile", response.body
  end

  test "member can update email and password from profile edit" do
    sign_in users(:one)

    patch my_profile_path, params: {
      profile: {
        user_attributes: {
          id: users(:one).id,
          email: "ada.updated@example.com",
          password: "NewPassword123!",
          password_confirmation: "NewPassword123!"
        }
      }
    }

    assert_redirected_to profile_path(profiles(:one))

    users(:one).reload
    assert_equal "ada.updated@example.com", users(:one).email
    assert users(:one).valid_password?("NewPassword123!")
  end

  test "free member cannot add more than one book" do
    sign_in users(:one)

    patch my_profile_path, params: {
      profile: {
        books_attributes: {
          "0" => {
            title: "Second Book",
            purchase_url: "https://bookshop.example.com/second-book"
          }
        }
      }
    }

    assert_response :unprocessable_entity
    assert_match "Free plan allows 1 book", response.body
    assert_match "Upgrade to PAID", response.body
    assert_equal 1, profiles(:one).books.count
  end
end
