class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one_attached :profile_img
  has_many :articles, dependent: :destroy 
  has_many :likes, dependent: :destroy 

  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy 
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy 
  has_many :following, through: :active_relationships, source: :followed 
  has_many :followers, through: :passive_relationships

  has_many :article_comments, dependent: :destroy 

  has_many :article_comment_likes, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable 

  before_save { self.email = email.downcase }
  
  validates :name, presence: { message: "を入力してください。"}, length: { maximum: 50 } 
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: { message: "を入力してください。"}, length: { maximum: 255, message: "は最大255文字です。" }, 
                    format: { with: VALID_EMAIL_REGEX, message: "は無効です。" },
                    uniqueness: { message: "はすでに使われています。"}
  validates :password, length: { minimum: 6, message: "は6文字以上を設定してください。" }, allow_nil: true 

  validates :introduction, length: { maximum: 100 }

  with_options presence: true do 
    with_options on: :create do 
      validates :password, presence: { message: "を入力してください。"} 
      validates :password_confirmation, presence: { message: "を入力してください。"} 
    end 
  end 

  def update_without_current_password(params, * options)
    params.delete(:current_password) 

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end 

    result = update(params, *options) 
    clean_up_passwords 
    result 
  end 

  # ユーザーをフォローする
  def follow(other_user) 
    following << other_user unless self == other_user 
  end 

  # ユーザーをフォロー解除する
  def unfollow(other_user) 
    following.delete(other_user) 
  end 

  # 現在のユーザーが他のユーザーをフォローしていればtrueを返す 
  def following?(other_user) 
    following.include?(other_user) 
  end 

  def feed 
    following_ids = "SELECT followed_id FROM relationships 
                     WHERE follower_id = :user_id" 
    Article.where("user_id IN (#{following_ids})
                   OR user_id = :user_id", user_id: id).limit(15) 
           .includes(:user, image_attachment: :blob)
  end 

  def self.ransackable_associations (auth_object = nil) 
    ["article"] 
  end 
end
