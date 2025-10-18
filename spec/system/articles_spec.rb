require 'rails_helper'

RSpec.describe 'Articles', type: :system, js: true do

  describe '#show' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'user login(article user)' do
      before do
        sign_in user
        visit root_path
        expect(page).to have_link('プロフィール画像', visible: true)
        click_link 'プロフィール画像', match: :first, exact: true

        expect(page).to have_link('プロフィール', visible: true)
        click_link 'プロフィール', match: :first, exact: true

        expect(page).to have_link(article.title, visible: true)
        click_link article.title, match: :first
      end

      it '記事の編集や削除のリンクを表示するケバブメニューがあること' do 
        expect(page).to have_css('.dli-more-v')
      end

      it '記事の編集ページへのリンクがあること' do
        expect(page).to have_link('option', visible: true)
        click_link 'option'

        expect(page).to have_content('記事を編集')
      end

      it '記事を削除するリンクがあること' do
        expect(page).to have_link('option', visible: true)
        click_link 'option'

        expect(page).to have_content('記事を削除')
      end
    end

    context 'user login(other user)' do
      before do
        sign_in other_user
        visit root_path
        visit "/articles/#{article.id}"
      end

      it '記事の編集や削除のリンクを表示するケバブメニューがないこと' do
        expect(page).to_not have_css('#option')
      end
    end

    context 'as a non logged in user' do
      before do
        visit root_path
        visit "/articles/#{article.id}"
      end

      it '記事の編集や削除のリンクを表示するケバブメニューがないこと' do
        expect(page).to_not have_css('#option')
      end
    end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'as a logged in user(correct user)' do
      before do
        sign_in user
        visit root_path
        expect(page).to have_link('プロフィール画像', visible: true)
        click_link 'プロフィール画像', match: :first, exact: true

        expect(page).to have_link('プロフィール', visible: true)
        click_link 'プロフィール', match: :first, exact: true

        expect(page).to have_link(article.title, visible: true)
        click_link article.title, match: :first

        expect(page).to have_link('option', visible: true)
        click_link 'option'
      end

      it '削除した記事がプロフィールページの記事一覧にないこと' do
        expect(page).to have_link('記事を削除', visible: true)
        page.accept_confirm do
          click_link '記事を削除'
        end

        expect(page).to_not have_content(article.title, exact: true)
      end

     it '確認ダイアログでキャンセルを選択すると記事が削除されないこと' do
        expect(page).to have_link('記事を削除', visible: true)
        page.dismiss_confirm do
          click_link '記事を削除'
        end

        expect(page).to have_current_path("/articles/#{article.id}")
      end
    end
  end
end
