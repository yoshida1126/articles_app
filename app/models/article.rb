class Article < ApplicationRecord
  has_one_attached :image do |attachble|
    attachble.variant :display, resize_to_limit: [200, 200] 
  end 
  has_many_attached :article_images
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true 
  validates :title, presence: true, length: { maximum: 50 } 
  validates :content, presence: true 
  validates :image, content_type: { in: %w[image/jpeg image/png image/gif],
                                    message: "アップロード可能な画像形式はJPEG, PNG, GIFです。ファイル形式をご確認ください。"},
                    size:         { less_than: 5.megabytes,
                                    message: "5MB以下の画像をアップロードしてください。" }
end
