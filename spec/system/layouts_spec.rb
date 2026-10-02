require 'rails_helper'

RSpec.describe 'Layouts', type: :system do
  let(:user) { FactoryBot.create(:user) }

  describe 'header' do
    context 'when logged in' do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in user
        visit root_path
      end

      describe 'Account dropdown menu' do
        before do
          click_link 'プロフィール画像', match: :first, exact: true
        end

        it 'redirects to the profile page when clicking the profile link' do
          click_link 'プロフィール', match: :first, exact: true
          expect(page).to have_current_path "/users/#{user.id}"
        end

        it 'redirects to the account edit page when clicking the edit account link' do
          click_link 'アカウント情報の編集', match: :first
          expect(page).to have_current_path edit_user_path(user)
        end

        it 'redirects to the root path when clicking the logout link' do
          click_link 'ログアウト', match: :first
          expect(page).to have_current_path root_path
        end

        it 'redirects to the new draft page when clicking the post article button' do
          click_link '投稿する', match: :first
          expect(page).to have_current_path new_user_article_draft_path(user)
        end

        it 'redirects to the root path when clicking the Articles link' do
          # rootに遷移することを確認するために編集ページに移動する
          click_link 'アカウント情報の編集', match: :first
          click_link 'Articles'
          expect(page).to have_current_path root_path
        end
      end
    end

    context 'when a non-logged-in user' do
      before do
        visit root_path
      end

      it 'redirects to the login page when clicking the login link' do
        click_link 'ログイン'
        expect(page).to have_current_path login_path
      end

      it 'redirects to the root path when clicking the Articles link' do
        # rootに遷移することを確認するために会員登録ページに移動する
        click_link '会員登録'
        click_link 'Articles'
        expect(page).to have_current_path root_path
      end
    end
  end
end
