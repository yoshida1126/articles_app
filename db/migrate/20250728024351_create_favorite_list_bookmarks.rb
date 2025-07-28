class CreateFavoriteListBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :favorite_list_bookmarks do |t|
      t.integer :bookmarking_user_id
      t.integer :favorite_list_id

      t.timestamps
    end
    add_index :favorite_list_bookmarks, :bookmarking_user_id
    add_index :favorite_list_bookmarks, :favorite_list_id
    add_index :favorite_list_bookmarks, [:bookmarking_user_id, :favorite_list_id], unique: true, name: "index_fav_list_bookmarks_on_user_id_and_fav_list_id"
  end
end
