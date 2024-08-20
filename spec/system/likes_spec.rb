require 'rails_helper' 

RSpec.describe "Likes", type: :system do 
    before do 
        driven_by(:rack_test)
    end 
end 

describe "#create" do 
  let(:user) { FactoryBot.create(:user) } 
  let!(:article) { FactoryBot.create(:article) } 

  context "as a logged in user(at home page)" do 
    before do 
      sign_in user 
      visit root_path
    end 

    it "いいねボタンがあること" do 
      expect(page).to have_css "#like-btn" 
    end 

    it "いいねできること" do 
      first("#like-btn").click 
      expect(page).to have_css "#unlike-btn"
    end 

    it "ページ遷移しないこと" do 
      first('#like-btn').click 
      expect(current_path).to eq root_path 
    end  
  end 

  context "as a logged in user(at article page)" do 
    before do 
      sign_in user 
      visit "/articles/#{article.id}"
    end 

    it "いいねボタンがあること" do 
      expect(page).to have_css "#like-btn"
    end 

    it "いいねできること" do 
      find("#like-btn").click 
      expect(page).to have_css "#unlike-btn"  
    end 

    it "ページ遷移しないこと" do 
        find('#like-btn').click 
        expect(current_path).to eq "/articles/#{article.id}" 
    end 
  end 

  context "as a non logged in user" do
    it "いいねボタンを押すとログインページにリダイレクトされること" do 
      visit root_path 
      first('#like-btn').click 
      sleep 0.2
      expect(current_path).to eq login_path
    end 
  end 

  context "as a non logged in user (at article page)" do 
    it "いいねボタンを押すとログインページにリダイレクトされること" do 
      visit "/articles/#{article.id}" 
      find('#like-btn').click 
      sleep 0.2 
      expect(current_path).to eq login_path 
    end 
  end 
end 

describe "#destroy" do 
  let(:user) { FactoryBot.create(:user) } 
  let!(:article) { FactoryBot.create(:article) } 

  context "as a logged in user(at home page)" do 
    before do 
      sign_in user 
      visit root_path 
      first("#like-btn").click 
      sleep 0.2
    end 

    it "すでにいいねされたボタンがあること" do 
      expect(page).to have_css "#unlike-btn" 
    end 

    it "いいねを解除できること" do 
      first("#unlike-btn").click 
      expect(page).to have_css "#like-btn" 
    end 

    it "ページ遷移しないこと" do 
      first("#unlike-btn").click 
      expect(current_path).to eq root_path 
    end 
  end 

  context "as a logged in user (at article page)" do 
    before do 
      sign_in user 
      visit root_path 
      click_link "Test article", match: :first
      find("#like-btn").click 
    end 

    it "すでにいいねされたボタンがあること" do 
      expect(page).to have_css "#unlike-btn" 
    end 

    it "いいねを解除できること" do  
      find("#unlike-btn").click  
      expect(page).to have_css "#like-btn" 
    end 

    it "ページ遷移しないこと" do  
      find("#unlike-btn").click 
      expect(current_path).to eq "/articles/#{article.id}"
    end 
  end 
end 