require 'rails_helper'

RSpec.describe FavoriteListBookmark, type: :model do
  describe 'validation' do
    let(:favorite_list_bookmark) { FactoryBot.create(:favorite_list_bookmark) }

    context 'with invalid attributes' do
      it 'is invalid without a user_id' do
        favorite_list_bookmark.user = nil
        expect(favorite_list_bookmark).to_not be_valid
      end

      it 'is invalid without a favorite_article_list_id' do
        favorite_list_bookmark.favorite_article_list = nil
        expect(favorite_list_bookmark).to_not be_valid
      end
    end
  end
end
