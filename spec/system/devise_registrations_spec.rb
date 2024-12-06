require 'rails_helper'

RSpec.describe 'Registrations', type: :system, js: true do

  describe '#create' do
    let(:user) { FactoryBot.create(:user) }

    context 'with valid information' do
      it '成功時のメッセージが表示されること' do
        valid_user_params = FactoryBot.attributes_for(:user)
        visit root_path
        click_link '会員登録'
        fill_in 'ユーザー名', with: valid_user_params[:name]
        fill_in 'メールアドレス', with: valid_user_params[:email]
        fill_in 'パスワード', with: valid_user_params[:password]
        fill_in 'パスワード（確認用）', with: valid_user_params[:password_confirmation]
        click_button "登　録"
        sleep 2
        expect(page).to have_selector 'div.alert-success'
      end
    end

    context 'with invalid information' do
      it 'エラーメッセージが表示されること' do
        visit root_path
        click_link '会員登録'
        fill_in 'ユーザー名', with: ''
        fill_in 'メールアドレス', with: 'example@invalid'
        fill_in 'パスワード', with: 'test1111'
        fill_in 'パスワード（確認用）', with: 'tes'
        click_button '登　録'

        expect(page).to have_selector 'div#error_explanation'
        expect(page).to have_selector 'div.alert-danger'
      end
    end
  end
end