require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "#help" do
    it "正常にレスポンスを返すこと" do
      get static_pages_help_path
      expect(response).to have_http_status :ok
    end
  end

  describe "#about" do
    it "正常にレスポンスを返すこと" do
      get static_pages_about_path
      expect(response).to have_http_status :ok 
    end
  end

end
