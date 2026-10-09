class ArticleDraft < ApplicationRecord
  has_one_attached :image # 記事のヘッダー画像
  has_many_attached :article_images # 記事本文に使う画像

  has_paper_trail on: [] # 必要なタイミングで記事の変更履歴を保存する

  belongs_to :user
  belongs_to :article, optional: true

  acts_as_taggable_on :tags

  default_scope -> { order(created_at: :desc) }
  scope :editing, -> { where(editing: true) }

  validates :user_id, presence: true
  validates :title, length: { maximum: 50 }
end
