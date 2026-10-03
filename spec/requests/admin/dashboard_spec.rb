require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do

  let(:admin_user) { FactoryBot.create(:admin_user) }
  let(:user) { FactoryBot.create(:user) }

  describe '#index' do

    context 'when logged in as an admin user' do 
      before do
        sign_in admin_user
      end

      it 'allows access to the admin dashboard' do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged in as a non-admin user' do
      before do
        sign_in user
      end

      it 'denies access to the admin dashboard' do
        get admin_root_path
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the root path' do 
        get admin_root_path
        expect(response).to redirect_to root_path
      end 
    end
  end
end
