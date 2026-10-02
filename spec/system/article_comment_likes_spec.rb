require 'rails_helper'

RSpec.describe 'ArticleCommentLikes', type: :system, js: true do
 
  describe '#create' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user)}
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    before do
      sign_in user
      visit article_path(article)
    end

    it 'displays the like button in the comment section' do
      expect(page).to have_css('#article-comment-like-btn', visible: true)
    end

    it 'allows liking a comment' do
      find('#article-comment-like-btn').click
      expect(page).to have_css('#article-comment-unlike-btn', visible: true)
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user)}
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    before do
      sign_in user
      visit article_path(article)

      expect(page).to have_css('#article-comment-like-btn', visible: true)
      find('#article-comment-like-btn').click

      expect(page).to have_css('#article-comment-unlike-btn', visible: true)
    end

    it 'displays the button as liked' do
      expect(page).to have_css('#article-comment-unlike-btn', visible: true)
    end

    it 'allows unliking the comment' do
      find('#article-comment-unlike-btn').click

      expect(page).to have_css('#article-comment-like-btn', visible: true)
    end
  end
end
