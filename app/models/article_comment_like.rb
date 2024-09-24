class ArticleCommentLike < ApplicationRecord
    belongs_to :user 
    belongs_to :article_comment

    validates_uniqueness_of :article_comment_id, scope: :user_id 
end 
