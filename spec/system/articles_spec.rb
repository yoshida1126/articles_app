require 'rails_helper'

RSpec.describe 'Articles', type: :system, js: true do

  describe '#show' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article_draft) { FactoryBot.create(:article_draft)}
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id, article_draft: article_draft) }
    

    context 'when the author views the article' do
      before do
        sign_in user
        visit article_path(article)
      end

      it 'displays the kebab menu for article actions' do 
        expect(page).to have_css('.dli-more-v')
      end

      it 'displays the link to edit the article' do
        expect(page).to have_link('option', visible: true)
        click_link 'option'

        expect(page).to have_content('記事を編集')
      end

      it 'displays the link to delete the article' do
        expect(page).to have_link('option', visible: true)
        click_link 'option'

        expect(page).to have_content('記事を削除')
      end
    end

    context 'when another user views the article' do
      before do
        sign_in other_user
        visit root_path
        visit "/articles/#{article.id}"
      end

      it 'does not display the kebab menu' do
        expect(page).to_not have_css('#option')
      end
    end

    context 'when a non-logged-in user views the article' do
      before do
        visit root_path
        visit "/articles/#{article.id}"
      end

      it 'does not display the kebab menu' do
        expect(page).to_not have_css('#option')
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article_draft) { FactoryBot.create(:article_draft)}
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id, article_draft: article_draft) }

    context 'when the author deletes the article' do
      before do
        sign_in user
        visit article_path(article)

        expect(page).to have_link('option', visible: true)
        click_link 'option'
      end

      it 'removes the deleted article from the article list on the profile page' do
        expect(page).to have_link('記事を削除', visible: true)
        page.accept_confirm do
          click_link '記事を削除'
        end

        expect(page).to_not have_content(article.title, exact: true)
      end

     it 'does not delete the article when the confirmation dialog is canceled' do
        expect(page).to have_link('記事を削除', visible: true)
        page.dismiss_confirm do
          click_link '記事を削除'
        end

        expect(page).to have_current_path("/articles/#{article.id}")
      end
    end
  end
end
