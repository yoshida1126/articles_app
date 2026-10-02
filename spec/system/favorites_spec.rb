require 'rails_helper'

RSpec.describe 'Favorites', type: :system, js: true do

  let(:user) { FactoryBot.create(:user, :with_relationships, :with_favorite_article_lists) }
  let!(:article) { FactoryBot.create(:article, user: user) }
  let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user:user) }

  describe '#create' do
    before do
      sign_in user
      visit root_path
      click_link 'Test article', match: :first, exact: true
      select('Test', from: 'favorite[favorite_article_list_id]')
      click_button 'リストに追加'
    end

    it 'allows adding an article to a list' do
      expect(page).to have_selector 'div.alert-success'
    end

    it 'displays the added article in the list' do
      visit user_favorite_article_lists_path(user)
      find('.article-link').click
      expect(page).to have_content 'Test article'
    end
  end

  describe '#destroy' do
    before do
      sign_in user
      visit root_path
      click_link 'Test article', match: :first, exact: true
      select('Test', from: 'favorite[favorite_article_list_id]')
      click_button 'リストに追加'
      visit user_favorite_article_lists_path(user)
      find('.article-link').click
      click_link 'リストを編集'
      click_button '削 除', match: :first
    end

    it 'allows removing an article from a list' do
      expect(page).to have_selector 'div.alert-success'
    end

    it 'removes the deleted article from the list' do
      visit user_favorite_article_lists_path(user)
      find('.article-link').click
      expect(page).to have_content 'Test'
    end
  end
end