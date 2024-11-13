require 'rails_helper'

RSpec.describe FavoriteArticleList, type: :model do
  let(:favorite_article_list) { FactoryBot.create(:favorite_article_list) }

  describe 'validation' do
    context 'with valid attributes' do
      it 'バリデーションが通ること' do
        expect(favorite_article_list).to be_valid
      end

      it '20文字のタイトルでバリデーションが通ること(境界値)' do
        favorite_article_list.list_title = 'a' * 20
        expect(favorite_article_list).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'ユーザーidがないとバリデーションが通らないこと' do
        favorite_article_list.user_id = nil
        expect(favorite_article_list).to_not be_valid
      end

      it 'タイトルがないとバリデーションが通らないこと' do
        favorite_article_list.list_title = nil
        expect(favorite_article_list).to_not be_valid
      end

      it 'タイトルが21文字以上だとバリデーションが通らないこと' do
        favorite_article_list.list_title = 'a' * 21
        expect(favorite_article_list).to_not be_valid
      end
    end
  end
end
