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
    assert_match(/Save Books (&|&amp;) Profile/, response.body)
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

  test "free member does not see featured book toggle" do
    sign_in users(:one)

    get edit_my_profile_path

    assert_response :success
    assert_no_match "Mark as featured book", response.body
  end

  test "free member cannot set featured via forged params" do
    sign_in users(:one)

    book = books(:one)
    book.update_column(:featured, false)

    patch my_profile_path, params: {
      profile: {
        books_attributes: {
          "0" => {
            id: book.id,
            title: book.title,
            purchase_url: book.purchase_url,
            featured: "1"
          }
        }
      }
    }

    assert_redirected_to profile_path(profiles(:one))
    assert_not book.reload.featured?
  end

  test "paid member can set featured" do
    sign_in users(:two)

    book = books(:two)
    book.update_column(:featured, false)

    patch my_profile_path, params: {
      profile: {
        books_attributes: {
          "0" => {
            id: book.id,
            title: book.title,
            purchase_url: book.purchase_url,
            featured: "1"
          }
        }
      }
    }

    assert_redirected_to profile_path(profiles(:two))
    assert book.reload.featured?
  end

  test "eligible member can feature only one book at a time" do
    sign_in users(:one)
    users(:one).update_column(:manual_paid, true)

    first_book = books(:one)
    second_book = first_book.profile.books.create!(
      title: "Second Eligible Book",
      purchase_url: "https://bookshop.example.com/eligible-second-book"
    )

    patch my_profile_path, params: {
      profile: {
        books_attributes: {
          "0" => {
            id: first_book.id,
            title: first_book.title,
            purchase_url: first_book.purchase_url,
            featured: "1"
          },
          "1" => {
            id: second_book.id,
            title: second_book.title,
            purchase_url: second_book.purchase_url,
            featured: "1"
          }
        }
      }
    }

    assert_response :unprocessable_entity
    assert_match "You can feature only 1 book at a time.", response.body
  end

  test "paid author shows verified badge on profile page" do
    get profile_path(profiles(:two))

    assert_response :success
    assert_match "verified-author-badge", response.body
    assert_match "Verified Featured Author", response.body
  end

  test "free author does not show verified badge on profile page" do
    users(:one).update_columns(manual_paid: false, featured_author: false)

    get profile_path(profiles(:one))

    assert_response :success
    assert_no_match "verified-author-badge", response.body
  end

  test "free author with admin featured override shows verified badge" do
    users(:one).update_column(:featured_author, true)

    get profile_path(profiles(:one))

    assert_response :success
    assert_match "verified-author-badge", response.body
  end

  test "featured-author banner appears for verified featured author" do
    users(:one).update_column(:manual_paid, true)

    get profile_path(profiles(:one))

    assert_response :success
    assert_match "Featured Author", response.body
    assert_match "featured-author-banner", response.body
  end
end
