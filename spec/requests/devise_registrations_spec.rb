require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe '#create' do
    let!(:other_user) { FactoryBot.create(:other_user) }

    context 'with valid information' do
      before do
        @valid_user_params = FactoryBot.attributes_for(
          :user,
          profile_img: fixture_file_upload('spec/fixtures/profile.jpg')
        )
      end
      it '登録できること' do
        get sign_up_path
        expect do
          post sign_up_path, params: { user: @valid_user_params }
        end.to change(User, :count).by 1
      end

      it '登録後ホームページにリダイレクトされること' do
        post sign_up_path, params: { user: @valid_user_params }
        expect(response).to redirect_to root_path
      end

      it '認証後ログインできること' do
        post sign_up_path, params: { user: @valid_user_params }
        user = User.last
        user.confirm
        sign_in(user)
        get "/users/#{user.id}"
        expect(response).to have_http_status :ok
      end

      it '認証後でないとログインできないこと' do
        post sign_up_path, params: { user: @valid_user_params }
        user = User.last
        sign_in(user)
        expect(response).to_not have_http_status :ok
      end

      it '認証後でないと登録したユーザーのプロフィールページにアクセスできないこと' do
        post sign_up_path, params: { user: @valid_user_params }
        user = User.last
        # 登録したユーザーのプロフィールページにアクセスするために他のユーザー
        # でログインする
        sign_in(other_user)
        get "/users/#{user.id}"
        expect(response).to_not have_http_status :ok
      end
    end

    context 'with invalid information' do
      it '登録できないこと' do
        get sign_up_path
        expect do
          post sign_up_path, params: { user: { name: '',
                                               email: 'test@invalid',
                                               password: 'test',
                                               password_confirmation: '' } }
        end.to_not change(User, :count)
      end
    end
  end

  describe '#edit' do
    let(:user) { FactoryBot.create(:user) }

    context 'as a logged in user' do
      before do
        sign_in(user)
      end

      it '編集ページにアクセスできること' do
        get edit_user_path(user)
        expect(response.body).to include('アカウント情報の編集')
      end
    end

    context 'as a non logged in user' do
      before do
        @user_params = { email: user.email,
                         password: 'test1111' }
        get edit_user_path(user)
      end

      it 'flashが表示されること' do
        expect(flash).to be_any
      end

      it 'ログインページにリダイレクトされること' do
        expect(response).to redirect_to login_path
      end

      it 'ログインした場合は編集ページにリダイレクトされること' do
        post login_path, params: { user: @user_params }
        expect(response).to redirect_to edit_user_path(user)
      end

      it '１回目のリクエストのみフレンドリーフォワーディングが適用されること' do
        post login_path, params: { user: @user_params }
        expect(response).to redirect_to edit_user_path(user)
        sign_out(user)
        post login_path, params: { user: @user_params }
        expect(response).to redirect_to root_url
      end
    end

    context 'as a wrong user' do
      before do
        wrong_user = FactoryBot.create(:other_user)
        sign_in(wrong_user)
      end

      it 'ルートパスにリダイレクトされること' do
        get edit_user_path(user)
        expect(response).to redirect_to root_url
      end
    end
  end

  describe '#update' do
    let(:user) { FactoryBot.create(:user) }

    context 'as a wrong user' do
      before do
        wrong_user = FactoryBot.create(:other_user)
        another_user_params = { name: 'Another name',
                                email: 'another@example.com',
                                password: '',
                                password_confirmation: '' }
        sign_in(wrong_user)
        patch user_path(user), params: { user: another_user_params }
      end

      it 'ルートパスにリダイレクトされること' do
        expect(response).to redirect_to root_url
      end
    end

    context 'with valid information(as a logged in user)' do
      before do
        sign_in(user)
        @valid_user_params = { name: 'valid user',
                               email: 'valid_user@example.com',
                               password: '',
                               password_confirmation: '' }
      end

      it 'ユーザー情報の編集に成功すること' do
        patch user_path(user), params: { user: @valid_user_params }
        user.reload
        expect(user.name).to eq @valid_user_params[:name]
        expect(user.email).to eq @valid_user_params[:email]
      end

      it 'プロフィールページにリダイレクトされること' do
        patch user_path(user), params: { user: @valid_user_params }
        expect(response).to redirect_to user_path(user)
      end

      it '成功時のフラッシュメッセージが表示されること' do
        patch user_path(user), params: { user: @valid_user_params }
        expect(flash).to be_any
      end
    end

    context 'with invalid information(as a logged in user)' do
      let(:invalid_user_params) { FactoryBot.attributes_for(:invalid_user) }

      before do
        sign_in(user)
      end

      it 'ユーザー情報の編集に失敗すること' do
        get edit_user_path(user)
        patch user_path(user), params: { user: invalid_user_params }
        user.reload
        expect(user.name).to_not eq invalid_user_params[:name]
        expect(user.email).to_not eq invalid_user_params[:email]
        expect(user.password).to_not eq invalid_user_params[:password]
        expect(user.password_confirmation).to_not eq invalid_user_params[:password_confirmation]
      end

      it '編集ページにリダイレクトされること' do
        patch user_path(user), params: { user: invalid_user_params }
        expect(response.body).to include 'アカウント情報の編集'
      end

      it '正しいエラーメッセージが表示されること' do
        patch user_path(user), params: { user: invalid_user_params }
        expect(response.body).to include '3件のエラーが含まれています。'
      end
    end

    context 'as a non logged in user' do
      before do
        @another_user_params = { name: 'Another name',
                                 email: 'another@example.com',
                                 password: '',
                                 password_confiamtion: '' }
        patch user_path(user), params: { user: @another_user_params }
      end

      it '編集できないこと' do
        user.reload
        expect(user.name).to_not eq @another_user_params[:name]
        expect(user.email).to_not eq @another_user_params[:email]
      end

      it 'ログインページにリダイレクトされること' do
        expect(response).to redirect_to login_path
      end

      it 'flashが表示されること' do
        expect(flash).to be_any
      end
    end
  end

  describe '#delete' do
    let!(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'as a non-logged in user' do
      it 'ログインページにリダイレクトされること' do
        delete delete_path(user)
        expect(response).to redirect_to login_url
      end

      it '削除できないこと' do
        expect do
          delete delete_path(user)
        end.to_not change(User, :count)
      end
    end

    context 'as a logged in user' do
      before do
        sign_in(user)
      end

      it '削除できること' do
        expect do
          delete delete_path(user)
        end.to change(User, :count)
      end

      it 'ルートパスにリダイレクトされること' do
        delete delete_path(user)
        expect(response).to redirect_to root_url
      end

      it 'flashが表示されること' do
        delete delete_path(user)
        expect(flash).to be_any
      end
    end

    context 'as a wrong user' do
      before do
        sign_in(other_user)
      end

      it '削除できないこと' do
        expect do
          delete delete_path(user)
        end.to_not change(User, :count)
      end
    end
  end
end
