require 'rails_helper'

RSpec.describe "Articles", type: :request do

  let(:user) { FactoryBot.create(:user) } 
  let(:article) { FactoryBot.create(:article) }

  describe "#new" do

    context "" do
      it "returns http success" do
        sign_in user
        get "/articles/new"
        expect(response).to have_http_status(:success)
      end 
    end
  end
end
