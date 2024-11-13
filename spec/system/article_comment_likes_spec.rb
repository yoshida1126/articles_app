require 'rails_helper'

RSpec.describe 'Likes', type: :system do
  before do
    driven_by(:rack_test)
  end
end

describe '#create' do
  let!(:user) { FactoryBot.create(:user) }
  let!(:article) { Article.create(title: 'test', content: 'test', tag_list: 'test', user_id: user.id) }
  let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

  context 'as a logged in user' do
    before do
      sign_in user
      visit root_path
      click_link 'プロフィール画像', match: :first, exact: true
      click_link 'プロフィール', match: :first, exact: true
      click_link "#{article.title}", exact: true
    end

    it 'コメント欄にいいねボタンがあること' do
      expect(page).to have_css '#article-comment-like-btn'
    end

    it 'コメントにいいねできること' do
      first('#article-comment-like-btn').click
      expect(page).to have_css '#article-comment-unlike-btn'
    end
  end

  context 'as a non logged in user' do
    before do
      visit root_path
      click_link "#{article.title}", match: :first
    end

    it 'いいねボタンを押すとログインページにリダイレクトされること' do
      first('#article-comment-like-btn').click
      sleep 0.2
      expect(current_path).to eq login_path
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
      click_link "#{article.title}", exact: true
      first('#article-comment-like-btn').click
      sleep 0.2
    end

    it 'すでにいいねされたボタンがあること' do
      expect(page).to have_css '#article-comment-unlike-btn'
    end

    it 'いいねを解除できること' do
      first('#article-comment-unlike-btn').click
      expect(page).to have_css '#article-comment-like-btn'
    end
  end
end
