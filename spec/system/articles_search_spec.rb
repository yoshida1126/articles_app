require 'rails_helper'

RSpec.describe "Search", type: :system do 
  before do 
    driven_by(:rack_test)
  end 
end 

describe "#search" do 
  let(:user) { FactoryBot.create(:user) } 
  let!(:article) { Article.create(title: "test", content: "test", user_id: user.id) }

  context "search article" do 
    before do 
      visit root_path 
      fill_in 'q_title_or_content_eq', with: "test", match: :first
      find("#search-btn").click
    end 

    it "検索結果に検索キーワードを含む記事があること" do 
      expect(page).to have_content(article.title)
    end 
  end 
end 