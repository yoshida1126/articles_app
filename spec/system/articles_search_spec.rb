require 'rails_helper'

RSpec.describe 'Search', type: :system, js: true do
  
  describe '#search' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }
    let!(:draft) { Article.create(published: false, title: 'draft article', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'when searching for articles by keywords' do
      before do
        visit root_path
        fill_in 'q_title_or_content_cont', with: 'test article'
        find('#search-btn').click
      end

      it 'displays that 1 result was found' do
        fill_in 'q_title_or_content_cont', with: 'test article'
        find('#search-btn').click
        expect(page).to have_content("検索結果 1 件")
      end

      it 'does not include drafts in the search results' do
        fill_in 'q_title_or_content_cont', with: 'draft article'
        find('#search-btn').click
        expect(page).to have_content("検索結果 0 件")
      end
    end

    context 'when searching for articles by tags' do
      before do
        visit root_path
      end

      it "allows searching by tags" do
        fill_in 'q_title_or_content_cont', with: '#test'
        find('#search-btn').click

        expect(page).to have_content("タグ: testの一覧 (1件)")
      end

      it "does not include drafts in the tag search results" do
        fill_in 'q_title_or_content_cont', with: '#test'
        find('#search-btn').click

        expect(page).to have_content("タグ: testの一覧 (1件)")
      end
    end
  end
end 
