require 'rails_helper'

RSpec.describe Article, type: :model do

  describe 'association' do
    let(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.create(:article) }
    let!(:article_draft) do
      FactoryBot.create(:article_draft, article: article)
    end

    it 'eletes associated articles when the user is deleted' do
      user = article.user
      expect do
        user.destroy
      end.to change(Article, :count).by(-1)
    end

    it 'deletes associated drafts when the article is deleted' do
      expect do
        article.destroy
      end.to change(ArticleDraft, :count).by(-1)
    end
  end

  describe 'validation' do
    let(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.build(:article) }

    context 'with valid attributes' do
      it 'is valid' do
        article.user = user
        expect(article).to be_valid
      end

      it 'is valid with a 50-character title' do
        article.user = user
        article.title = 'a' * 50
        expect(article).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without a user' do
        article.user_id = nil
        expect(article).to_not be_valid
      end

      it 'is invalid without a title' do
        article.title = nil
        expect(article).to_not be_valid
      end

      it 'is invalid with a title longer than 50 characters' do
        article.title = 'a' * 51
        expect(article).to_not be_valid
      end

      it 'is invalid without content' do
        article.content = ''
        expect(article).to_not be_valid
      end
    end
  end
end
