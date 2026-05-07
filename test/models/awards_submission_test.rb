require "test_helper"

class AwardsSubmissionTest < ActiveSupport::TestCase
  test "requires required fields" do
    submission = AwardsSubmission.new

    assert_not submission.valid?
    assert_includes submission.errors[:first_name], "can't be blank"
    assert_includes submission.errors[:last_name], "can't be blank"
    assert_includes submission.errors[:author_email], "can't be blank"
    assert_includes submission.errors[:book_title], "can't be blank"
    assert_includes submission.errors[:book_url], "can't be blank"
  end

  test "generates a public token on validation" do
    submission = AwardsSubmission.new(
      first_name: "Kara",
      last_name: "Miller",
      author_email: "kara@example.com",
      book_title: "Sunrise Stories",
      book_url: "https://books.example.com/sunrise"
    )

    assert submission.valid?
    assert submission.public_token.present?
  end

  test "rejects invalid required book URL" do
    submission = AwardsSubmission.new(
      first_name: "Kara",
      last_name: "Miller",
      author_email: "kara@example.com",
      book_title: "Sunrise Stories",
      book_url: "not-a-url"
    )

    assert_not submission.valid?
    assert_includes submission.errors[:book_url], "must be a valid URL"
  end
end
