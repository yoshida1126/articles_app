class AddEditingToArticleDraft < ActiveRecord::Migration[7.0]
  def change
    add_column :article_drafts, :editing, :boolean, default: false
  end
end
