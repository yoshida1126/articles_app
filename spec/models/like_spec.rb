require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:like) { FactoryBot.create(:like) }
  let(:other_like) { FactoryBot.build(:like) }

  describe 'validation' do
    context 'when the user is logged in' do
      it 'is valid' do
        expect(like).to be_valid
      end

      it 'does not allow a user to like the same article more than once' do
        other_like.user = like.user
        other_like.article = like.article
        expect(other_like).to_not be_valid
      end
    end

    context 'when the user is not logged in' do
      it 'is invalid' do
        like.user = nil
        expect(like).to_not be_valid
      end
    end
  end
end
