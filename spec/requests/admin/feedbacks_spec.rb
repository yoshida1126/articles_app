require 'rails_helper'

RSpec.describe 'Admin::Feedbacks', type: :request do

  let(:admin_user) { FactoryBot.create(:admin_user) } 
  let(:user) { FactoryBot.create(:user, :with_feedback) }
  let!(:feedback) { user.feedbacks.first }

  describe '#index' do

    context 'when logged in as an admin user' do 
      before do 
        sign_in admin_user 
      end

      it 'allows access to the feedback index page' do
        get "/admin/feedbacks"
        expect(response).to have_http_status(:success)
      end
    end 

    context 'when logged in as a non-admin user' do
      before do 
        sign_in user
      end

      it 'redirects to the root page' do
        get "/admin/feedbacks"
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#destroy' do
    before do
      sign_in admin_user
    end

    it 'allows an admin user to delete feedback' do 
      expect {
        delete admin_feedback_path(feedback), headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
      }.to change(Feedback, :count).by -1
    end 
  end
end
