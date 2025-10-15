class RenameDraftColumnToArticle < ActiveRecord::Migration[7.0]
  def change
    rename_column :articles, :draft, :published
  end
end
