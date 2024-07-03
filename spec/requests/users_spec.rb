require 'rails_helper'

RSpec.describe "Users", type: :request do
  let (:user) { FactoryBot.create(:user) }

  before do 
    sign_in user 
  end 

  describe "GET /show" do

    it "returns http success" do
      get "/users/#{user.id}"
      expect(response).to have_http_status :ok
    end
  end

end
