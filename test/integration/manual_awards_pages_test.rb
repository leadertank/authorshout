require "test_helper"

class ManualAwardsPagesTest < ActionDispatch::IntegrationTest
  test "winners page displays editor choice and section links" do
    get awards_winners_path

    assert_response :success
    assert_match "7th Annual Author Shout Book Award Winners", response.body
    assert_match "Editor's Choice", response.body
    assert_match "View All", response.body
  end

  test "winners page paginates top picks by eight" do
    9.times do |index|
      ManualAward.create!(
        title: "Top Pick #{index}",
        author_name: "Author #{index}",
        top_pick: true,
        created_at: index.minutes.ago
      )
    end

    get awards_winners_path

    assert_response :success
    assert_match "Top Pick 0", response.body
    assert_no_match "Top Pick 8", response.body

    get awards_winners_path(top_pick_page: 2)

    assert_response :success
    assert_match "Top Pick 8", response.body
  end

  test "category pages list assigned books" do
    get awards_top_picks_path
    assert_response :success
    assert_match "7th Annual Author Shout Book Awards Top Picks", response.body

    get awards_recommended_reads_path
    assert_response :success
    assert_match "7th Annual Author Shout Book Awards Recommended Reads", response.body

    get awards_honorable_mentions_path
    assert_response :success
    assert_match "7th Annual Author Shout Book Awards Honorable Mentions", response.body
  end

  test "admin can create a manual award entry" do
    sign_in users(:two)

    post admin_manual_awards_path, params: {
      manual_award: {
        title: "Admin Added Award",
        author_name: "Dashboard Author",
        book_url: "https://example.com/admin-added-award",
        top_pick: "1",
        primary_page: "top_picks_page"
      }
    }

    assert_redirected_to admin_manual_awards_path
    follow_redirect!
    assert_response :success
    assert_match "Admin Added Award", response.body
  end
end
