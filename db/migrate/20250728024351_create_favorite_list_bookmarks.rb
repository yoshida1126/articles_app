class CreateFavoriteListBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :favorite_list_bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :favorite_article_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
