require 'rails_helper'

RSpec.describe 'ArticleCommentLikes', type: :system, js: true do
 
  describe '#create' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
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
      end

      it 'コメント欄にいいねボタンがあること' do
        expect(page).to have_css('#article-comment-like-btn', visible: true)
      end

      it 'コメントにいいねできること' do
        find('#article-comment-like-btn').click
        expect(page).to have_css('#article-comment-unlike-btn', visible: true)
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
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

        expect(page).to have_css('#article-comment-like-btn', visible: true)
        find('#article-comment-like-btn').click

        expect(page).to have_css('#article-comment-unlike-btn', visible: true)
      end

      it 'すでにいいねされたボタンがあること' do
        expect(page).to have_css('#article-comment-unlike-btn', visible: true)
      end

      it 'いいねを解除できること' do
        find('#article-comment-unlike-btn').click

        expect(page).to have_css('#article-comment-like-btn', visible: true)
      end
    end
  end
end
