require 'rails_helper'

RSpec.describe ArticleCommentLike, type: :model do
  let(:article_comment_like) { FactoryBot.create(:article_comment_like) }

  describe 'validation' do
    context 'with valid attributes' do
      it 'バリデーションが通ること' do
        expect(article_comment_like).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'ユーザーidがないとバリデーションが通らないこと' do
        article_comment_like.user = nil
        expect(article_comment_like).to_not be_valid
      end

      it 'コメントのidがないとバリデーションが通らないこと' do
        article_comment_like.article_comment = nil
        expect(article_comment_like).to_not be_valid
      end
    end
  end
end
