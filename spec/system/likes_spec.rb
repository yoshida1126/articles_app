require 'rails_helper'

RSpec.describe 'Likes', type: :system, js: true do

  describe '#create' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { FactoryBot.create(:article) }

    context 'as a logged in user(at home page)' do
      before do
        sign_in user
        visit root_path
      end

      it 'いいねボタンがあること' do
        expect(page).to have_css('#like-btn', visible: true)
      end

      it 'いいねできること' do
        first('#like-btn').click
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'ページ遷移しないこと' do
        first('#like-btn').click
        expect(page).to have_current_path(root_path)
      end
    end

    context 'as a logged in user(at article page)' do
      before do
        sign_in user
        visit "/articles/#{article.id}"
      end

      it 'いいねボタンがあること' do
        expect(page).to have_css('#like-btn', visible: true)
      end

      it 'いいねできること' do
        find('#like-btn').click
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'ページ遷移しないこと' do
        find('#like-btn').click
        expect(page).to have_current_path("/articles/#{article.id}")
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { FactoryBot.create(:article) }

    context 'as a logged in user(at home page)' do
      before do
        sign_in user
        visit root_path
        find('#like-btn').click
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'すでにいいねされたボタンがあること' do
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'いいねを解除できること' do
        first('#unlike-btn').click
        expect(page).to have_css('#like-btn', visible: true)
      end

      it 'ページ遷移しないこと' do
        first('#unlike-btn').click
        expect(page).to have_current_path(root_path)
      end
    end

    context 'as a logged in user (at article page)' do
      before do
        sign_in user
        visit root_path

        expect(page).to have_link('Test article', visible: true)
        click_link 'Test article', match: :first

        expect(page).to have_css('#like-btn', visible: true)
        find('#like-btn').click

        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'すでにいいねされたボタンがあること' do
        expect(page).to have_css('#unlike-btn', visible: true)
      end

      it 'いいねを解除できること' do
        find('#unlike-btn').click
        expect(page).to have_css('#like-btn', visible: true)
      end

      it 'ページ遷移しないこと' do
        find('#unlike-btn').click
        expect(page).to have_current_path("/articles/#{article.id}")
      end
    end
  end
end
