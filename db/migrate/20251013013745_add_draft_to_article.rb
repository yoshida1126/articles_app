class AddDraftToArticle < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :draft, :boolean, default: true
  end
end
