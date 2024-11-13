require 'rails_helper'

RSpec.describe ArticleComment, type: :model do
  let(:article_comment) { FactoryBot.create(:article_comment) }

  describe 'validation' do
    context 'with valid attributes' do
      it 'バリデーションが通ること' do
        expect(article_comment).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'ユーザーidがないとバリデーションが通らないこと' do
        article_comment.user = nil
        expect(article_comment).to_not be_valid
      end

      it '記事のidがないとバリデーションが通らないこと' do
        article_comment.article = nil
        expect(article_comment).to_not be_valid
      end

      it 'コメントの内容が空だとバリデーションが通らないこと' do
        article_comment.comment = ''
        expect(article_comment).to_not be_valid
      end
    end
  end
end
