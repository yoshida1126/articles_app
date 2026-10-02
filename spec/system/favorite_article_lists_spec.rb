require 'rails_helper'

RSpec.describe 'FavoriteArticleLists', type: :system, js: true do

  let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }

  describe '#index' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
    end

    it 'displays the list created by the user' do
      expect(page).to have_content 'Test'
    end

    it 'displays the link to create a new shared list' do
      expect(page).to have_link '新規シェアリストを作成する'
    end
  end

  describe '#show' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
      find('.article-link').click
    end

    it 'displays the link to edit the list' do
      expect(page).to have_link 'リストを編集'
    end

    it 'displays the link to delete the list' do
      expect(page).to have_link 'リストを削除'
    end
  end

  describe '#new' do
    before do
      @user = FactoryBot.create(:user)
    end

    before do
      sign_in @user
      visit user_favorite_article_lists_path(@user)
      click_link '新規シェアリストを作成する'
    end

    it 'successfully accesses the list creation page' do
      expect(page).to have_content 'リストの作成'
    end
  end

  describe '#create' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
      click_link '新規シェアリストを作成する'
      fill_in 'favorite_article_list[list_title]', with: 'List Title'
      click_button '作　成'
    end

    it 'successfully creates the list' do
      expect(page).to have_selector 'div.alert-success'
    end

    it 'redirects to the list index page after creation' do
      expect(page).to have_current_path user_favorite_article_lists_path(user)
    end

    it 'displays the created list in the list index' do
      expect(page).to have_content 'List Title'
    end
  end

  describe '#update' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
      find('.article-link').click
      click_link 'リストを編集'
      fill_in 'favorite_article_list[list_title]', with: 'Edit Title'
      click_button '編　集'
    end

    it 'successfully updates the list' do
      expect(page).to have_selector 'div.alert-success'
    end

    it 'redirects to the list index page after update' do
      expect(page).to have_current_path user_favorite_article_lists_path(user)
    end

    it 'displays the updated title in the list index' do
      expect(page).to have_content 'Edit Title'
    end
  end

  describe '#destroy' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
      find('.article-link').click
      page.accept_confirm do
        click_link 'リストを削除'
      end
    end

    it 'successfully deletes the list' do
      expect(page).to have_selector 'div.alert-success'
    end

    it 'redirects to the list index page after deletion' do
      expect(page).to have_current_path user_favorite_article_lists_path(user)
    end

    it 'removes the deleted title from the list index' do
      expect(page).to have_content 'Test'
    end
  end
end