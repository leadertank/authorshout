class BookAwardWinnersController < ApplicationController
  def index
    @award_pages = [
      {
        title: "7th Annual Author Shout Book Award Winners",
        description: "Browse the official 7th annual winners page, including Editor's Choice, Top Pick, Recommended Read, and Honorable Mention sections.",
        path: awards_winners_path
      }
    ]
  end
end
