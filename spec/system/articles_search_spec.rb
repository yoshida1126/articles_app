require 'rails_helper'

RSpec.describe 'Search', type: :system, js: true do
  
  describe '#search' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'search article' do
      before do
        visit root_path
        fill_in 'q_title_or_content_eq', with: 'test article'
        find('#search-btn').click
      end

      it '検索結果に検索キーワードを含む記事があること' do
        expect(page).to have_content(article.title)
      end
    end
  end
end 
