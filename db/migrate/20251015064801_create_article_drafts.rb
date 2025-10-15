class CreateArticleDrafts < ActiveRecord::Migration[7.0]
  def change
    create_table :article_drafts do |t|
      t.string :title
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :article, foreign_key: true, null: true

      t.timestamps
    end
  end
end
