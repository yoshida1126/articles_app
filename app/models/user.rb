class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable 

  before_save { self.email = email.downcase }
  
  validates :name, presence: true, length: { maximum: 50 } 
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  with_options presence: true do 
    with_options on: :create do 
      validates :password 
      validates :password_confirmation  
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
end
