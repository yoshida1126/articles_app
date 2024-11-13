class CreateArticleCommentLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :article_comment_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article_comment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
