class AddArticleCommentLikesCountToArticleComments < ActiveRecord::Migration[7.0]
  def up
    add_column :article_comments, :article_comment_likes_count, :integer, default: 0, null: false

    execute <<~SQL
      UPDATE article_comments
      SET article_comment_likes_count = (
        SELECT COUNT(*)
        FROM article_comment_likes
        WHERE article_comment_likes.article_comment_id = article_comments.id
      )
    SQL
  end

  def down
    remove_column :article_comments, :article_comment_likes_count
  end
end
