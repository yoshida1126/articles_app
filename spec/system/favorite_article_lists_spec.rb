require 'rails_helper'

RSpec.describe 'FavoriteArticleLists', type: :system do
  before do
    driven_by(:rack_test)
  end
end

describe '#index' do
  let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }

  context 'as a logged in user' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
    end

    it 'リスト一覧にユーザーが作成したリストがあること' do
      expect(page).to have_content 'Test'
    end

    it '新しいリストを作成するリンクがあること' do
      expect(page).to have_link '新しいリストの作成'
    end
  end
end

describe '#show' do
  let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }

  context 'as a logged in user' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
      click_link 'Test'
    end

    it 'リストを編集するリンクがあること' do
      expect(page).to have_link 'リストを編集'
    end

    it 'リストを削除するリンクがあること' do
      expect(page).to have_link 'リストを削除'
    end
  end
end

describe '#new' do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'as a logged in user' do
    before do
      sign_in @user
      visit user_favorite_article_lists_path(@user)
      click_link 'リストを作成'
    end

    it 'リストの作成ページにアクセスできること' do
      expect(page).to have_content 'リストの作成'
    end
  end
end

describe '#create' do
  let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }

  context 'as a logged in user' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
      click_link 'リストの作成'
      fill_in 'favorite_article_list[list_title]', with: 'List Title'
      click_button '作　成'
    end

    it 'リストの作成に成功すること' do
      expect(page).to have_selector 'div.alert-success'
    end

    it 'リストの作成後は、リスト一覧ページにリダイレクトされること' do
      expect(page).to have_current_path user_favorite_article_lists_path(user)
    end

    it 'リストの一覧に作成したリストがあること' do
      expect(page).to have_content 'List Title'
    end
  end
end

describe '#update' do
  let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }

  context 'as a logged in user' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
      click_link 'Test'
      click_link 'リストを編集'
      fill_in 'favorite_article_list[list_title]', with: 'Edit Title'
      click_button '編 集'
    end

    it 'リストの編集に成功すること' do
      expect(page).to have_selector 'div.alert-success'
    end

    it 'リストの編集後はリスト一覧ページにリダイレクトされること' do
      expect(page).to have_current_path user_favorite_article_lists_path(user)
    end

    it 'リストの一覧に編集したリストのタイトルがあること' do
      expect(page).to have_content 'Edit Title'
    end
  end
end

describe '#destroy' do
  let(:user) { FactoryBot.create(:user, :with_favorite_article_lists) }

  context 'as a logged in user' do
    before do
      sign_in user
      visit user_favorite_article_lists_path(user)
      click_link 'Test'
      page.accept_confirm do
        click_link 'リストを削除'
      end
    end

    it 'リストの削除に成功すること' do
      expect(page).to have_selector 'div.alert-success'
    end

    it 'リストの削除後はリスト一覧ページにリダイレクトされること' do
      expect(page).to have_current_path user_favorite_article_lists_path(user)
    end

    it 'リストの一覧から削除したリストのタイトルが消えること' do
      expect(page).to have_content 'Test'
    end
  end
end
