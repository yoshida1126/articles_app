require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do

  let(:admin_user) { FactoryBot.create(:admin_user) }
  let(:user) { FactoryBot.create(:user) }

  describe "#index" do

    context "as a logged in admin user" do 
      before do
        sign_in admin_user
      end

      it '管理者トップページにアクセスできること' do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as a logged in non admin user" do
      before do
        sign_in user
      end

      it "管理者トップページにアクセスできないこと" do
        get admin_root_path
        expect(response).to have_http_status(:redirect)
      end

      it "ルートパスにリダイレクトされること" do 
        get admin_root_path
        expect(response).to redirect_to root_path
      end 
    end
  end
end
