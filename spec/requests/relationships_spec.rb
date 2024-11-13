require 'rails_helper'

RSpec.describe 'Relationships', type: :request do
  describe '#create' do
    context 'as a logged in user' do
      before do
        @user = FactoryBot.create(:user)
        @other_user = FactoryBot.create(:other_user)
        sign_in @user
      end

      it 'フォローできること' do
        expect do
          post relationships_path, params: { followed_id: @other_user.id }
        end.to change(Relationship, :count).by 1
      end
    end

    context 'as a non-logged in user' do
      it 'ログインページにリダイレクトされること' do
        post relationships_path
        expect(response).to redirect_to login_path
      end

      it 'リレーションシップテーブルが作成されないこと' do
        expect do
          post relationships_path
        end.to_not change(Relationship, :count)
      end
    end
  end

  describe '#destroy' do
    let!(:relationship) { FactoryBot.create(:relationship) }
    context 'as a logged in user' do
      before do
        @user = FactoryBot.create(:user)
        @other_user = FactoryBot.create(:other_user)
        sign_in @user
      end

      it 'フォローを解除できること' do
        @user.follow(@other_user)
        created_relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
        expect do
          delete relationship_path(created_relationship)
        end.to change(Relationship, :count).by(-1)
      end
    end

    context 'as a non-logged in user' do
      it 'ログインページにリダイレクトされること' do
        delete relationship_path(relationship)
        expect(response).to redirect_to login_path
      end

      it 'リレーションシップテーブルを削除できないこと' do
        expect do
          delete relationship_path(relationship)
        end.to_not change(Relationship, :count)
      end
    end
  end
end
