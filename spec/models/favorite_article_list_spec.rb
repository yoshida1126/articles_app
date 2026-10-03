require 'rails_helper'

RSpec.describe FavoriteArticleList, type: :model do
  let(:favorite_article_list) { FactoryBot.create(:favorite_article_list) }

  describe 'validation' do
    context 'with valid attributes' do
      it 'is valid' do
        expect(favorite_article_list).to be_valid
      end

      it 'is valid with a 20-character title' do
        favorite_article_list.list_title = 'a' * 20
        expect(favorite_article_list).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without a user' do
        favorite_article_list.user_id = nil
        expect(favorite_article_list).to_not be_valid
      end

      it 'is invalid without a title' do
        favorite_article_list.list_title = nil
        expect(favorite_article_list).to_not be_valid
      end

      it 'is invalid with a title longer than 20 characters' do
        favorite_article_list.list_title = 'a' * 21
        expect(favorite_article_list).to_not be_valid
      end
    end
  end
end
