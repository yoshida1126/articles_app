require 'rails_helper'

RSpec.describe "MainPages", type: :request do
  describe 'root' do 
    it "responds successfully" do
      get root_path 
      expect(response).to have_http_status :ok
    end 

    it "have a correct title" do 
      get root_path
      expect(response.body).to include "<title>Articles</title>" 
    end 
  end 

end
