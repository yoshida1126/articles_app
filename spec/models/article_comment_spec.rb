require 'rails_helper'

RSpec.describe ArticleComment, type: :model do
  let(:article_comment) { FactoryBot.create(:article_comment) }

  describe 'validation' do
    context 'is valid' do
      it 'バリデーションが通ること' do
        expect(article_comment).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without a user' do
        article_comment.user = nil
        expect(article_comment).to_not be_valid
      end

      it 'is invalid without an article' do
        article_comment.article = nil
        expect(article_comment).to_not be_valid
      end

      it 'is invalid with an empty comment' do
        article_comment.comment = ''
        expect(article_comment).to_not be_valid
      end
    end
  end
end
