require "test_helper"

class ManualAwardTest < ActiveSupport::TestCase
  test "requires at least one award designation" do
    award = ManualAward.new(title: "Untitled", author_name: "Anon")

    assert_not award.valid?
    assert_includes award.errors.full_messages, "Select at least one awards designation"
  end

  test "primary page sets the matching award toggle" do
    award = ManualAward.create!(
      title: "Primary Page Example",
      author_name: "Page Author",
      primary_page: :recommended_reads_page
    )

    assert award.recommended_read?
  end

  test "only one editor choice remains active" do
    first = manual_awards(:editors_choice)
    second = ManualAward.create!(
      title: "New Editor Pick",
      author_name: "Another Author",
      editor_choice: true
    )

    assert second.reload.editor_choice?
    assert_not first.reload.editor_choice?
  end
end
