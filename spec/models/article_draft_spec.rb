require 'rails_helper'

RSpec.describe ArticleDraft, type: :model do
  describe 'association' do
    let(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.create(:article) }
    let!(:article_draft) do
      FactoryBot.create(:article_draft, article: article)
    end

    it 'deletes associated drafts when the user is deleted' do
      user = article.user
      expect do
        user.destroy
      end.to change(ArticleDraft, :count).by(-1)
    end

    it 'does not delete the associated article when the draft is deleted' do
      expect do
        article_draft.destroy
      end.to change(Article, :count).by(0)
    end
  end

  describe 'validation' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article_draft) do
      FactoryBot.create(:article_draft)
    end

    context 'with valid attributes' do

      it 'is valid' do
        expect(article_draft).to be_valid
      end

      it 'is valid with a 50-character title' do
        article_draft.title = 'a' * 50
        expect(article_draft).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without a user' do
        article_draft.user_id = nil
        expect(article_draft).to_not be_valid
      end

      it 'is invalid with a title longer than 50 characters' do
        article_draft.title = 'a' * 51
        expect(article_draft).to_not be_valid
      end
    end
  end
end
