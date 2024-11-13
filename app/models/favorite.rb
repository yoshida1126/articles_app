class Favorite < ApplicationRecord
  belongs_to :article
  belongs_to :favorite_article_list

  validates :favorite_article_list, presence: true
  validates :article, presence: true
end
