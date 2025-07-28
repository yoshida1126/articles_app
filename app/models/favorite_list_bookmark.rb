class FavoriteListBookmark < ApplicationRecord
    def change
        create_table :favorite_list_bookmark do |t|
            t.integer :bookmarking_user_id
            t.integer :favorite_list_id

            t.timestamps
        end
        add_index :favorite_list_bookmark, :bookmarking_user_id
        add_index :favorite_list_bookmark, :favorite_list_id
        add_index :favorite_list_bookmark, [:bookmarking_user_id, :favorite_list_id], unique: true
    end
end
