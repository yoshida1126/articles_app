require 'rails_helper'

RSpec.describe 'MainPages', type: :system do

  describe 'root' do
    describe 'feed' do
      let(:user) { FactoryBot.create(:user, :with_articles) }
      before do
        sign_in user
      end

      it 'フィードが正しく表示されていること' do
        visit root_path
        user.feed.each do |article|
          expect(page).to have_content(CGI.escapeHTML(article.title))
        end
      end
    end
  end
end 
