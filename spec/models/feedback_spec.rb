require 'rails_helper'

RSpec.describe Feedback, type: :model do
  let(:user) { FactoryBot.create(:user, :with_feedback) }
  let!(:feedback) { user.feedbacks.first }

  describe 'association' do
    it 'deletes associated feedback when the user is deleted' do
      expect do
        user.destroy
      end.to change(Feedback, :count).by(-1)
    end
  end

  describe 'validation' do
    context 'with valid attributes' do
      it 'is valid' do
        expect(feedback).to be_valid
      end

      it 'is valid with a 50-character subject' do
        feedback.subject = 'a' * 50
        expect(feedback).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without a user' do
        feedback.user_id = nil
        expect(feedback).to_not be_valid
      end

      it 'is invalid without a subject' do
        feedback.subject = nil
        expect(feedback).to_not be_valid
      end

      it 'is invalid with a subject longer than 50 characters' do
        feedback.subject = 'a' * 51
        expect(feedback).to_not be_valid
      end

      it 'is invalid without a feedback body' do
        feedback.body = ''
        expect(feedback).to_not be_valid
      end
    end
  end
end
