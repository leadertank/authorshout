class AwardsWinnersController < ApplicationController
  BOOKS_PER_PAGE = 8

  def index
    @editor_choice = ManualAward.editor_choices.first

    @top_pick_books, @top_pick_page, @top_pick_total_pages = paginated_scope(
      ManualAward.top_picks,
      :top_pick_page
    )

    @recommended_read_books, @recommended_read_page, @recommended_read_total_pages = paginated_scope(
      ManualAward.recommended_reads,
      :recommended_read_page
    )

    @honorable_mention_books, @honorable_mention_page, @honorable_mention_total_pages = paginated_scope(
      ManualAward.honorable_mentions,
      :honorable_mention_page
    )
  end

  def top_picks
    @books = ManualAward.top_picks
  end

  def recommended_reads
    @books = ManualAward.recommended_reads
  end

  def honorable_mentions
    @books = ManualAward.honorable_mentions
  end

  private

  def paginated_scope(scope, key)
    records = scope.to_a
    total_pages = [ (records.size.to_f / BOOKS_PER_PAGE).ceil, 1 ].max
    page = normalized_page(params[key], total_pages)
    window = records.slice((page - 1) * BOOKS_PER_PAGE, BOOKS_PER_PAGE) || []

    [ window, page, total_pages ]
  end

  def normalized_page(value, total_pages)
    page = value.to_i
    page = 1 if page < 1
    page > total_pages ? total_pages : page
  end
end
