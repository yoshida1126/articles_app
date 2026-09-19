class ArticleCommentLike < ApplicationRecord
  belongs_to :user
  belongs_to :article_comment, counter_cache: true

  validates_uniqueness_of :article_comment_id, scope: :user_id
end
