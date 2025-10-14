require 'rails_helper'

RSpec.describe 'FavoriteListBookmark', type: :system, js: true do

  let(:user) { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:other_user, :with_favorite_article_lists) }
  let!(:favorite_article_list) { other_user.favorite_article_lists.first }
  let!(:article) { Article.create(draft: false, title: "test", content: "test", tag_list: "test", user_id: user.id) }

  describe '#create' do
    before do
      sign_in user
      visit "/users/#{ other_user.id }/favorite_article_lists"
    end

    it "リストをブックマークできること" do
      find("#bookmark-btn-#{ favorite_article_list.id }").click
      expect(page).to have_selector '.unbookmark-btn'
    end
  end

  describe '#destroy' do
    before do
      sign_in user
      visit "/users/#{ other_user.id }/favorite_article_lists"
      find("#bookmark-btn-#{ favorite_article_list.id }").click
    end

    it "リストのブックマークを解除できること" do
      find("#unbookmark-btn-#{ favorite_article_list.id }").click
      expect(page).to have_selector '.bookmark-btn'
    end
  end
end