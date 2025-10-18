require 'rails_helper'

RSpec.describe ArticleDraft, type: :model do
  describe 'association' do
    let(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.create(:article) }
    let!(:article_draft) do
      FactoryBot.create(:article_draft, article: article)
    end

    it 'ユーザーが削除されたら結びついている下書きも削除されること' do
      user = article.user
      expect do
        user.destroy
      end.to change(ArticleDraft, :count).by(-1)
    end

    it '下書きを削除しても紐づいている記事が削除されないこと' do
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

      it 'バリデーションが通ること' do
        expect(article_draft).to be_valid
      end

      it '50文字のタイトルでバリデーションが通ること(境界値)' do
        article_draft.title = 'a' * 50
        expect(article_draft).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'ユーザーidがないとバリデーションが通らないこと' do
        article_draft.user_id = nil
        expect(article_draft).to_not be_valid
      end

      it 'タイトルがないとバリデーションが通らないこと' do
        article_draft.title = nil
        expect(article_draft).to_not be_valid
      end

      it 'タイトルが51文字以上だとバリデーションが通らないこと' do
        article_draft.title = 'a' * 51
        expect(article_draft).to_not be_valid
      end

      it 'contentがないとバリデーションが通らないこと' do
        article_draft.content = ''
        expect(article_draft).to_not be_valid
      end
    end
  end
end
