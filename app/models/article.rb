class Article < ApplicationRecord
  has_one_attached :image
  has_many_attached :article_images
  belongs_to :user
  has_many :likes, dependent: :destroy
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true 
  validates :title, presence: true, length: { maximum: 50 } 
  validates :content, presence: true 
  validates :image, content_type: { in: %w[image/jpeg image/png image/gif],
                                    message: "アップロード可能な画像形式はJPEG, PNG, GIFです。ファイル形式をご確認ください。"},
                    size:         { less_than: 5.megabytes,
                                    message: "5MB以下の画像をアップロードしてください。" }
            
  def liked?(user) 
    likes.where(user_id: user.id).exists? 
  end 
end

