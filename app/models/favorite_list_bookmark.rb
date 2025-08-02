class FavoriteListBookmark < ApplicationRecord
    belongs_to :user
    belongs_to :favorite_article_list

    validates :user, presence: true
    validates :favorite_article_list, presence: true
    validates_uniqueness_of :favorite_article_list, scope: :user_id
end
