require 'rails_helper'

RSpec.describe 'Likes', type: :system, js: true do
 
  describe '#create' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    context 'as a logged in user' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        click_link article.title, match: :first
      end

      it 'コメント欄にいいねボタンがあること' do
        expect(page).to have_css('#article-comment-like-btn', wait: 10)
      end

      it 'コメントにいいねできること' do
        find('#article-comment-like-btn').click
        expect(page).to have_css('#article-comment-unlike-btn', wait: 10)
      end
    end

    context 'as a non logged in user' do
      before do
        visit root_path
        click_link article.title, match: :first
      end

      it 'いいねボタンを押すとログインページにリダイレクトされること' do
        find('#article-comment-like-btn').click
        expect(page).to have_current_path(login_path, wait: 10)
      end
    end
  end

  describe '#destroy' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    context 'as a logged in user' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        click_link article.title, match: :first
        find('#article-comment-like-btn').click
      end

      it 'すでにいいねされたボタンがあること' do
        expect(page).to have_css('#article-comment-unlike-btn', wait: 10)
      end

      it 'いいねを解除できること' do
        find('#article-comment-unlike-btn').click
        expect(page).to have_css('#article-comment-like-btn', wait: 10)
      end
    end
  end
end