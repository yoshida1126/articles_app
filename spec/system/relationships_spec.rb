require 'rails_helper'

RSpec.describe 'Relationships', type: :system, js: true do

  describe '#create' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'when following another user' do
      before do
        sign_in user
        visit "/users/#{other_user.id}"
      end

      it 'displays the follow button' do
        expect(page).to have_css '.follow-btn'
      end

      it 'allows following the user' do
        click_button 'フォロー'
        expect(page).to have_css '.unfollow-btn'
      end

      it 'does not redirect or refresh the page' do
        click_button 'フォロー'
        expect(current_path).to eq "/users/#{other_user.id}"
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'when unfollowing the user' do
      before do
        sign_in user
        visit "/users/#{other_user.id}"
        click_button 'フォロー'
      end

      it 'displays the unfollow button' do
        expect(page).to have_css '.unfollow-btn'
      end

      it 'allows unfollowing the user' do
        click_button 'フォロー解除'
        expect(page).to have_css '.follow-btn'
      end

      it 'does not redirect or refresh the page' do
        click_button 'フォロー解除'
        expect(current_path).to eq "/users/#{other_user.id}"
      end
    end
  end
end