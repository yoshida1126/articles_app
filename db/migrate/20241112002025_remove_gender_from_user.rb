class RemoveGenderFromUser < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :gender, :boolean
  end
end
