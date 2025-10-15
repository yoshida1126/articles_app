class ArticleDraft < ApplicationRecord
  has_one_attached :image # 記事のヘッダー画像
  has_many_attached :article_images # 記事本文に使う画像
  belongs_to :user
  belongs_to :article, optional: true
end
