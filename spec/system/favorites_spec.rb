require 'rails_helper'

RSpec.describe "FavoriteArticleLists", type: :system do 
  before do 
    driven_by(:rack_test)
  end 
end 

describe "#create" do 
  let(:user) { FactoryBot.create(:user, :with_articles, :with_relationships, :with_favorite_article_lists) }  

  context "as a logged in user" do 
    before do 
      sign_in user 
      visit root_path 
      click_link "Test article", match: :first, exact: true 
      select(value = "Test", from: "favorite[favorite_article_list_id]")
      click_button "リストに追加" 
    end 

    it "リストに記事を追加できること" do 
      expect(page).to have_selector "div.alert-success" 
    end 

    it "リストに追加hした記事があること" do 
      visit user_favorite_article_lists_path(user)
      click_link "Test" 
      expect(page).to have_content "Test article" 
    end 
  end 
end 

describe "#destroy" do 
  let(:user) { FactoryBot.create(:user, :with_articles, :with_relationships, :with_favorite_article_lists) }

  context "as a logged in user" do 
    before do 
      sign_in user 
      visit root_path 
      click_link "Test article", match: :first, exact: true 
      select(value = "Test", from: "favorite[favorite_article_list_id]")
      click_button "リストに追加" 
      visit user_favorite_article_lists_path(user)
      click_link "Test" 
      click_link "リストを編集" 
      click_button "削 除" 
    end 

    it "リストから記事を削除できること" do
      expect(page).to have_selector "div.alert-success" 
    end 

    it "リストに削除した記事がないこと" do 
      visit user_favorite_article_lists_path(user)
      click_link "Test" 
      expect(page).to have_content "Test" 
    end 
  end
end 