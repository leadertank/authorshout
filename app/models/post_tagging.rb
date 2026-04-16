class PostTagging < ApplicationRecord
  belongs_to :post
  belongs_to :post_tag

  validates :post_tag_id, uniqueness: { scope: :post_id }
end