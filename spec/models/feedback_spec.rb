require 'rails_helper'

RSpec.describe Feedback, type: :model do
  let(:user) { FactoryBot.create(:user, :with_feedback) }
  let!(:feedback) { user.feedbacks.first }

  describe 'association' do
    it 'ユーザーが削除されたら結びついているフィードバックも削除されること' do
      expect do
        user.destroy
      end.to change(Feedback, :count).by(-1)
    end
  end

  describe 'validation' do
    context 'with valid attributes' do
      it 'バリデーションが通ること' do
        expect(feedback).to be_valid
      end

      it '50文字の件名でバリデーションが通ること(境界値)' do
        feedback.subject = 'a' * 50
        expect(feedback).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'ユーザーidがないとバリデーションが通らないこと' do
        feedback.user_id = nil
        expect(feedback).to_not be_valid
      end

      it '件名がないとバリデーションが通らないこと' do
        feedback.subject = nil
        expect(feedback).to_not be_valid
      end

      it '件名が51文字以上だとバリデーションが通らないこと' do
        feedback.subject = 'a' * 51
        expect(feedback).to_not be_valid
      end

      it 'フィードバック本文がないとバリデーションが通らないこと' do
        feedback.body = ''
        expect(feedback).to_not be_valid
      end
    end
  end
end
