require 'rails_helper'

RSpec.describe 'Relationships', type: :system, js: true do

  describe '#create' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'follow other user' do
      before do
        sign_in user
        visit "/users/#{other_user.id}"
      end

      it 'フォローボタンがあること' do
        expect(page).to have_css '.follow-btn'
      end

      it 'フォローできること' do
        click_button 'フォロー'
        expect(page).to have_css '.unfollow-btn'
      end

      it 'ページ遷移しないこと' do
        click_button 'フォロー'
        expect(current_path).to eq "/users/#{other_user.id}"
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'unfollow other user' do
      before do
        sign_in user
        visit "/users/#{other_user.id}"
        click_button 'フォロー'
      end

      it 'フォロー解除ボタンがあること' do
        expect(page).to have_css '.unfollow-btn'
      end

      it 'フォロー解除できること' do
        click_button 'フォロー解除'
        expect(page).to have_css '.follow-btn'
      end

      it 'ページ遷移しないこと' do
        click_button 'フォロー解除'
        expect(current_path).to eq "/users/#{other_user.id}"
      end
    end
  end
end