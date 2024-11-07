class CreateFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :favorites do |t|
      t.references :article, foreign_key: true
      t.references :favorite_article_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
