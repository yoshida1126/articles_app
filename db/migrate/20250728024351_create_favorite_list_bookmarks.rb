class CreateFavoriteListBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :favorite_list_bookmarks do |t|
      t.integer :bookmarking_user_id
      t.integer :favorite_list_id

      t.timestamps
    end
  end
end
