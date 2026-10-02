require 'rails_helper'

RSpec.describe 'Likes', type: :system, js: true do

  describe '#create' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { FactoryBot.create(:article) }

    context 'when liking an article from the home page' do
      before do
        sign_in user
        visit root_path
      end

      it 'displays the like button' do
        expect(page).to have_css('#like-btn', visible: true)
      end

      it 'allows liking the article' do
        first('#like-btn').click
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'does not redirect or refresh the page' do
        first('#like-btn').click
        expect(page).to have_current_path(root_path)
      end
    end

    context 'when liking an article from the article page' do
      before do
        sign_in user
        visit "/articles/#{article.id}"
      end

      it 'displays the like button' do
        expect(page).to have_css('#like-btn', visible: true)
      end

      it 'allows liking the article' do
        find('#like-btn').click
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'does not redirect or refresh the page' do
        find('#like-btn').click
        expect(page).to have_current_path("/articles/#{article.id}")
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { FactoryBot.create(:article) }

    context 'when unliking an article from the home page' do
      before do
        sign_in user
        visit root_path
        find('#like-btn').click
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'displays the button as liked' do
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'allows unliking the article' do
        first('#unlike-btn').click
        expect(page).to have_css('#like-btn', visible: true)
      end

      it 'does not redirect or refresh the page' do
        first('#unlike-btn').click
        expect(page).to have_current_path(root_path)
      end
    end

    context 'when unliking an article from the article page' do
      before do
        sign_in user
        visit root_path

        expect(page).to have_link('Test article', visible: true)
        click_link 'Test article', match: :first

        expect(page).to have_css('#like-btn', visible: true)
        find('#like-btn').click

        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'displays the button as liked' do
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'allows unliking the article' do
        find('#unlike-btn').click
        expect(page).to have_css('#like-btn', visible: true)
      end

      it 'does not redirect or refresh the page' do
        find('#unlike-btn').click
        expect(page).to have_current_path("/articles/#{article.id}")
      end
    end
  end
end
