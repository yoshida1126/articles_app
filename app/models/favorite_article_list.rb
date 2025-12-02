class FavoriteArticleList < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :articles, through: :favorites

  has_many :favorite_list_bookmarks, dependent: :destroy
  has_many :users, through: :favorite_list_bookmarks

  validates :user, presence: true
  validates :list_title, presence: true, length: { maximum: 20 }

  def favorite(article)
    articles << article
  end

  def unfavorite(favorite)
    favorites.destroy(favorite)
  end

  def self.ransackable_attributes(_auth_object = nil)
    ["list_title", "created_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end
