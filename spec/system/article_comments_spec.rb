require 'rails_helper'

RSpec.describe 'ArticleComments', type: :system, js: true do

  describe '#create' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }

    context 'when posting a valid comment' do
      before do
        sign_in user
        visit article_path(article)
      end

      it 'successfully posts a comment' do
        expect(page).to have_field('article_comment[comment]', visible: true)
        fill_in 'article_comment[comment]', with: 'Article Comment'

        click_button '送信する'

        expect(page).to have_content('Article Comment')
      end

      it 'attaches an image to the comment' do
        expect(page).to have_field('article_comment[comment]', visible: true)
        fill_in 'article_comment[comment]', with: 'Article Comment'

        attach_file 'article_comment[images][]', 'spec/fixtures/map.png', visible: false, match: :first

        click_button '送信する'
        expect(page).to have_selector("img[alt='map.png']", visible: true)
      end
    end

    context 'when posting an invalid comment' do
      before do
        sign_in user
        visit article_path(article)
      end

      it 'cannot post a comment when the form is empty' do
        expect(page).to have_field('article_comment[comment]', visible: true)
        fill_in 'article_comment[comment]', with: ''

        click_button '送信する'

        expect(page).to have_selector('div.alert-danger', visible: true)
      end
    end
  end

  describe '#update' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    context 'with valid updates' do
      before do
        sign_in user
        visit article_path(article)

        find('.dropdown3').click

        expect(page).to have_link('コメントを編集', visible: true)
        click_link 'コメントを編集'
      end

      it 'successfully updates the comment' do
        fill_in('article_comment[comment]', match: :first, visible: true, with: 'Edit Article Comment')

        click_button '編集'

        expect(page).to have_content('Edit Article Comment')
      end

      it 'attaches an image when updating the comment' do
        fill_in('article_comment[comment]', match: :first, visible: true, with: 'Edit Article Comment')
        attach_file 'article_comment[images][]', 'spec/fixtures/map.png', visible: false, match: :first

        click_button '編集'

        expect(page).to have_selector("img[alt='map.png']", visible: true)
      end
    end

    context 'with invalid updatesco' do
      before do
        sign_in user
        visit article_path(article)

        find('.dropdown3').click
        click_link 'コメントを編集'
      end

      it 'cannot update the comment when the form is empty' do
        fill_in('article_comment[comment]', match: :first, visible: true, with: '')
      
        click_button '編集'

        expect(page).to have_selector('div.alert-danger', visible: true)
      end
    end
  end

  describe '#destroy' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }
    let!(:article_comment) { ArticleComment.create(comment: 'Article Comment', user_id: user.id, article_id: article.id) }

    before do
      sign_in user
      visit article_path(article)

      find('.dropdown3').click

      expect(page).to have_link('コメントを削除', visible: true)
      page.accept_confirm do
        click_link 'コメントを削除'
      end
    end 

    it 'removes the deleted comment from the comment section' do
      expect(page).to have_no_content('Article Comment')
    end
  end
end