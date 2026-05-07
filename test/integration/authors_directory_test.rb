require "test_helper"

class AuthorsDirectoryTest < ActionDispatch::IntegrationTest
  test "featured authors page lists only featured-author or paid members" do
    users(:one).update_columns(manual_paid: false, featured_author: true)
    users(:two).update_columns(manual_paid: false, featured_author: true)

    paid_member = User.create!(
      email: "paid-author@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      first_name: "Paid",
      last_name: "Author",
      human_verification: "1"
    )
    paid_member.update_columns(manual_paid: true, featured_author: false)

    extra = User.create!(
      email: "not-featured@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      first_name: "No",
      last_name: "Badge",
      human_verification: "1"
    )
    extra.update_columns(manual_paid: false, featured_author: false)

    get featured_authors_path

    assert_response :success
    assert_match "Featured Authors:", response.body
    assert_match "Showing:", response.body
    assert_match "Ada Lovelace", response.body
    assert_match "Paid Author", response.body
    assert_no_match "Grace Hopper", response.body
    assert_no_match "No Badge", response.body
  end

  test "members directory supports letter filter and search" do
    get authors_directory_path(letter: "L")

    assert_response :success
    assert_match "Total Members:", response.body
    assert_match "Showing:", response.body
    assert_match "Ada Lovelace", response.body
    assert_no_match "Grace Hopper", response.body

    get authors_directory_path(q: "ada")

    assert_response :success
    assert_match "Ada Lovelace", response.body
    assert_no_match "Grace Hopper", response.body
  end

  test "author pages include cross-navigation links" do
    get featured_authors_path

    assert_response :success
    assert_match "Browse Full Members Directory", response.body

    get authors_directory_path

    assert_response :success
    assert_match "View Featured Authors", response.body
  end

  test "members directory renders numbered page chips when paginated" do
    28.times do |index|
      User.create!(
        email: "directory-member-#{index}@example.com",
        password: "Password123!",
        password_confirmation: "Password123!",
        first_name: "Dir#{index}",
        last_name: "Author#{index}",
        human_verification: "1"
      )
    end

    get authors_directory_path

    assert_response :success
    assert_match "Directory pages", response.body
    assert_match "?page=2", response.body
  end
end