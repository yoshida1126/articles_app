require 'rails_helper'

RSpec.describe 'ArticleComments', type: :system, js: true do

  describe '#create' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'as a logged in user(input correct article comment)' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}", exact: true
      end

      it 'コメントの投稿に成功すること' do
        fill_in 'article_comment[comment]', with: 'Article Comment'
        click_button '送信する'
        sleep 0.5
        expect(page).to have_content 'Article Comment'
      end

      it 'コメントに画像を貼れること' do
        fill_in 'article_comment[comment]', match: :first, with: 'Edit Article Comment'
        attach_file 'article_comment[images][]', 'spec/fixtures/map.png', visible: false, match: :first

        click_button '送信する'
        expect(page).to have_selector "img[alt='map.png']"
      end
    end

    context 'as a logged in user(input wrong article comment)' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}"
      end

      it 'コメントフォームが空だと投稿できないこと' do
        fill_in 'article_comment[comment]', with: ''
        click_button '送信する'
        sleep 0.5
        expect(page).to have_selector 'div.alert-danger'
      end
    end
  end

  describe '#update' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    context 'as a logged in user(input correct article comment)' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}"
        sleep 0.5
        page.first('.dropdown3').click
        click_link 'コメントを編集'
      end

      it '記事のコメントを編集できること' do
        fill_in 'article_comment[comment]', match: :first, with: 'Edit Article Comment'
        click_button '編集'
        sleep 0.2
        expect(page).to have_content 'Edit Article Comment'
      end

      it '編集するコメントに画像を貼れること' do
        fill_in 'article_comment[comment]', match: :first, with: 'Edit Article Comment'
        attach_file 'article_comment[images][]', 'spec/fixtures/map.png', visible: false, match: :first
        click_button '編集'
        expect(page).to have_selector "img[alt='map.png']"
      end
    end

    context 'as a logged in user(input wrong article comment)' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}"
        sleep 0.5
        page.first('.dropdown3').click
        click_link 'コメントを編集'
      end

      it 'コメントフォームが空だと編集できないこと' do
        fill_in 'article_comment[comment]', match: :first, with: ''
        click_button '編集'
        sleep 1
        expect(page).to have_selector 'div.alert-danger'
      end
    end
  end

  describe '#destroy' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    context 'as a logged in user' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}"
        page.first('.dropdown3').click
        page.accept_confirm do
          click_link 'コメントを削除'
        end
      end 

      it '削除したコメントがコメント欄にないこと' do
        sleep 0.5
        expect(page).to_not have_content 'Article Comment'
      end
    end
  end
end