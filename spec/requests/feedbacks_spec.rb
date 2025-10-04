require 'rails_helper'

RSpec.describe "Feedbacks", type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe "#new" do
    before do
      sign_in user
    end

    it 'フィードバック送信フォームページにアクセスできること' do
      get new_feedback_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do

    context "with valid information(as a logged in user)" do 
      before do 
        sign_in user 
        @valid_feedback_params = { 
          subject: "test",
          body: "test",
        }
      end 

      it "フィードバックの作成に成功すること" do
        expect {
          post feedbacks_path, params: { feedback: @valid_feedback_params }
        }.to change(Feedback, :count).by 1
      end 

      it "ルートパスにリダイレクトされること" do 
        post feedbacks_path, params: { feedback: @valid_feedback_params }
        expect(response).to redirect_to root_path
      end 
    end 

    context "with invalid information" do
      
      before do 
        @invalid_feedback_params = { 
          subject: "",
          body: "",
        }
        sign_in user 
      end 

      it "投稿できないこと" do
        expect {
          post feedbacks_path, params: { feedback: @invalid_feedback_params }
        }.to_not change(Feedback, :count)
      end 
    end  
  end
end
