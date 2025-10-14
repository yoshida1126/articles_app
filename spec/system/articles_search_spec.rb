require 'rails_helper'

RSpec.describe 'Search', type: :system, js: true do
  
  describe '#search' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(draft: false, title: 'test article', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'search article' do
      before do
        visit root_path
        fill_in 'q_title_or_content_eq', with: 'test article'
        find('#search-btn').click
      end

      it '検索結果 1 件 と表示されること' do
        expect(page).to have_content("検索結果 1 件")
      end
    end

    context 'search tag' do
      before do
        visit root_path
      end

      it "タグで検索できること" do
        fill_in 'q_title_or_content_eq', with: '#test'
        find('#search-btn').click

        expect(page).to have_content("タグ: testの一覧 (1件)")
      end

      it "存在しないタグを検索するとルートパスにリダイレクトされること" do
        fill_in 'q_title_or_content_eq', with: '#article'
        find('#search-btn').click

        expect(current_path).to eq root_path
        expect(page).to have_selector 'div.alert-danger'
      end
    end
  end
end 
