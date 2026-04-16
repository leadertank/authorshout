module ApplicationHelper
	def book_liked_by_current_actor?(book)
		book.liked_by?(user: current_user, visitor_token: current_visitor_token)
	end
end
