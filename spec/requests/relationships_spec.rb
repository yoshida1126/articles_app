require 'rails_helper'

RSpec.describe 'Relationships', type: :request do
  describe '#create' do
    context 'when the user is logged in' do
      before do
        @user = FactoryBot.create(:user)
        @other_user = FactoryBot.create(:other_user)
        sign_in @user
      end

      it 'allows the user to follow another user' do
        expect do
          post relationships_path, params: { followed_id: @other_user.id }
        end.to change(Relationship, :count).by 1
      end
    end

    context 'when the user is not logged in' do
      it 'redirects to the login page' do
        post relationships_path
        expect(response).to redirect_to login_path
      end

      it 'does not create a relationship' do
        expect do
          post relationships_path
        end.to_not change(Relationship, :count)
      end
    end
  end

  describe '#destroy' do
    let!(:relationship) { FactoryBot.create(:relationship) }
    context 'when the user is logged in' do
      before do
        @user = FactoryBot.create(:user)
        @other_user = FactoryBot.create(:other_user)
        sign_in @user
      end

      it 'allows the user to unfollow another user' do
        @user.follow(@other_user)
        created_relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
        expect do
          delete relationship_path(created_relationship)
        end.to change(Relationship, :count).by(-1)
      end
    end

    context 'when the user is not logged in' do
      it 'redirects to the login page' do
        delete relationship_path(relationship)
        expect(response).to redirect_to login_path
      end

      it 'does not delete the relationship' do
        expect do
          delete relationship_path(relationship)
        end.to_not change(Relationship, :count)
      end
    end
  end
end