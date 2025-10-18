require 'rails_helper'

RSpec.describe Article, type: :model do

  describe 'association' do
    let(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.create(:article) }
    let!(:article_draft) do
      FactoryBot.create(:article_draft, article: article)
    end

    it 'ユーザーが削除されたら結びついている記事も削除されること' do
      user = article.user
      expect do
        user.destroy
      end.to change(Article, :count).by(-1)
    end

    it '投稿記事を削除すると紐づいている下書きも削除されること' do
      expect do
        article.destroy
      end.to change(ArticleDraft, :count).by(-1)
    end
  end

  describe 'validation' do
    let(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.build(:article) }

    context 'with valid attributes' do
      it 'バリデーションが通ること' do
        article.user = user
        expect(article).to be_valid
      end

      it '50文字のタイトルでバリデーションが通ること(境界値)' do
        article.user = user
        article.title = 'a' * 50
        expect(article).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'ユーザーidがないとバリデーションが通らないこと' do
        article.user_id = nil
        expect(article).to_not be_valid
      end

      it 'タイトルがないとバリデーションが通らないこと' do
        article.title = nil
        expect(article).to_not be_valid
      end

      it 'タイトルが51文字以上だとバリデーションが通らないこと' do
        article.title = 'a' * 51
        expect(article).to_not be_valid
      end

      it 'contentがないとバリデーションが通らないこと' do
        article.content = ''
        expect(article).to_not be_valid
      end
    end
  end
end
