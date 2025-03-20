class Article < ApplicationRecord
  has_one_attached :image # 記事のヘッダー画像
  has_many_attached :article_images # 記事本文に使う画像
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :article_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_article_lists, through: :favorites
  acts_as_taggable_on :tags
  validates :tag_list, presence: { message: 'を入力してください。' }
  validate :validate_tag
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true
  validates :image, content_type: { in: %w[image/jpeg image/png image/gif],
                                    message: 'アップロード可能な画像形式はJPEG, PNG, GIFです。ファイル形式をご確認ください。' },
                    size: { less_than: 5.megabytes,
                            message: '5MB以下の画像をアップロードしてください。' },
                    dimension: { width: { min: 375, max: 1024 },
                                 height: { min: 360, max: 1024 } }

  def liked?(user)
    likes.where(user_id: user.id).exists?
  end

  def self.searchable_attributes
    %w[title content]
  end

  searchable_attributes.each do |field|
    scope "search_by_#{field}", ->(keyword) { where("#{field} LIKE ?", "%#{keyword}%") }
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[title content]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  private

  # 以下、タグの上限に関するコード
  # todo:
  # タグが10個までしかつけられないことを明示していないのは
  # 不親切であるため、後々改善する

  MAX_TAG_COUNT = 10

  def validate_tag
    return unless tag_list.size > MAX_TAG_COUNT

    errors.add('タグ', 'の数は10個以下にしてください。')
  end
end
