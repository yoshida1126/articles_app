class ArticleComment < ApplicationRecord
  has_many_attached :comment_images
  belongs_to :article
  belongs_to :user
  has_many :article_comment_likes, dependent: :destroy

  validates :comment, presence: true

  def liked?(user)
    # 二重にいいねできないように確認
    article_comment_likes.where(user_id: user.id).exists?
  end
end
