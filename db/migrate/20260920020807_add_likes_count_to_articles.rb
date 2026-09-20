class AddLikesCountToArticles < ActiveRecord::Migration[7.0]
  def up
    add_column :articles, :likes_count, :integer, default: 0, null: false

    execute <<~SQL
      UPDATE articles
      SET likes_count = (
        SELECT COUNT(*)
        FROM likes
        WHERE likes.article_id = articles.id
      )
    SQL
  end

  def down
    remove_column :articles, :likes_count
  end
end
