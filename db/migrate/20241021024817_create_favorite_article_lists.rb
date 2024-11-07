class CreateFavoriteArticleLists < ActiveRecord::Migration[7.0]
  def change
    create_table :favorite_article_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, foreign_key: true
      t.string :list_title

      t.timestamps
    end
  end
end
