require 'rails_helper'

RSpec.describe 'ArticleComments', type: :system, js: true do

  describe '#create' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(draft: false, title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'as a logged in user(input correct article comment)' do
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

      it 'コメントの投稿に成功すること' do
        expect(page).to have_field('article_comment[comment]', visible: true)
        fill_in 'article_comment[comment]', with: 'Article Comment'

        click_button '送信する'

        expect(page).to have_content('Article Comment')
      end

      it 'コメントに画像を貼れること' do
        expect(page).to have_field('article_comment[comment]', visible: true)
        fill_in 'article_comment[comment]', with: 'Edit Article Comment'

        attach_file 'article_comment[images][]', 'spec/fixtures/map.png', visible: false, match: :first

        click_button '送信する'
        expect(page).to have_selector("img[alt='map.png']", visible: true)
      end
    end

    context 'as a logged in user(input wrong article comment)' do
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

      it 'コメントフォームが空だと投稿できないこと' do
        expect(page).to have_field('article_comment[comment]', visible: true)
        fill_in 'article_comment[comment]', with: ''

        click_button '送信する'

        expect(page).to have_selector('div.alert-danger', visible: true)
      end
    end
  end

  describe '#update' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(draft: false, title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    context 'as a logged in user(input correct article comment)' do
      before do
        sign_in user
        visit root_path
        expect(page).to have_link('プロフィール画像', visible: true)
        click_link 'プロフィール画像', match: :first, exact: true

        expect(page).to have_link('プロフィール', visible: true)
        click_link 'プロフィール', match: :first, exact: true

        expect(page).to have_link(article.title, visible: true)
        click_link article.title, match: :first

        find('.dropdown3').click

        expect(page).to have_link('コメントを編集', visible: true)
        click_link 'コメントを編集'
      end

      it 'コメントを編集できること' do
        fill_in('article_comment[comment]', match: :first, visible: true, with: 'Edit Article Comment')

        click_button '編集'

        expect(page).to have_content('Edit Article Comment')
      end

      it '編集するコメントに画像を貼れること' do
        fill_in('article_comment[comment]', match: :first, visible: true, with: 'Edit Article Comment')
        attach_file 'article_comment[images][]', 'spec/fixtures/map.png', visible: false, match: :first

        click_button '編集'

        expect(page).to have_selector("img[alt='map.png']", visible: true)
      end
    end

    context 'as a logged in user(input wrong article comment)' do
      before do
        sign_in user
        visit root_path
        expect(page).to have_link('プロフィール画像', visible: true)
        click_link 'プロフィール画像', match: :first, exact: true

        expect(page).to have_link('プロフィール', visible: true)
        click_link 'プロフィール', match: :first, exact: true

        expect(page).to have_link(article.title, visible: true)
        click_link article.title, match: :first

        find('.dropdown3').click
        click_link 'コメントを編集'
      end

      it 'コメントフォームが空だと編集できないこと' do
        fill_in('article_comment[comment]', match: :first, visible: true, with: '')
      
        click_button '編集'

        expect(page).to have_selector('div.alert-danger', visible: true)
      end
    end
  end

  describe '#destroy' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(draft: false, title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    context 'as a logged in user' do
      before do
        sign_in user
        visit root_path
        expect(page).to have_link('プロフィール画像', visible: true)
        click_link 'プロフィール画像', match: :first, exact: true

        expect(page).to have_link('プロフィール', visible: true)
        click_link 'プロフィール', match: :first, exact: true

        expect(page).to have_link(article.title, visible: true)
        click_link article.title, match: :first

        find('.dropdown3').click

        expect(page).to have_link('コメントを削除', visible: true)
        page.accept_confirm do
          click_link 'コメントを削除'
        end
      end 

      it '削除したコメントがコメント欄にないこと' do
        expect(page).to have_no_content('Article Comment')
      end
    end
  end
end