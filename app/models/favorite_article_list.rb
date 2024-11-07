class FavoriteArticleList < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :articles, through: :favorites

  validates :user, presence: true 
  validates :list_title, presence: true, length: { maximum: 20 }

  def favorite(article)
    articles << article 
  end 

  def unfavorite(favorite)  
    favorites.destroy(favorite)
  end 
end
