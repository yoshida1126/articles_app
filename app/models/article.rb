class Article < ApplicationRecord
  has_one_attached :image
  has_many_attached :article_images
  belongs_to :user
  has_many :likes, dependent: :destroy
  acts_as_taggable_on :tags
  validates :tag_list, presence: { message: 'を入力してください。'}
  validate :validate_tag
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true 
  validates :title, presence: true, length: { maximum: 50 } 
  validates :content, presence: true 
  validates :image, content_type: { in: %w[image/jpeg image/png image/gif],
                                    message: "アップロード可能な画像形式はJPEG, PNG, GIFです。ファイル形式をご確認ください。"},
                    size:         { less_than: 5.megabytes,
                                    message: "5MB以下の画像をアップロードしてください。" },
                    dimension:    { width: { min: 375, max: 1024 },
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

  def self.ransackable_attributes (auth_object = nil) 
    ["title", "content"] 
  end 

  def self.ransackable_associations (auth_object = nil) 
    []
  end 

  private 

  MAX_TAG_COUNT = 10 

  def validate_tag 
    if tag_list.size > MAX_TAG_COUNT 
      errors.add("タグ", "の数は10個以下にしてください。")
    end 
  end
end 

