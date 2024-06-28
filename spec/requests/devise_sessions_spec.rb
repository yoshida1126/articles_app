require 'rails_helper' 

RSpec.describe "Sessions", type: :request do
    describe "#new" do 
      it "ログインページにアクセスできること" do 
        get login_path 
        expect(response).to have_http_status :ok
      end 
    end 

    describe "#create" do 
      
      let(:user) { FactoryBot.create(:user) }

      context "with valid information" do 
        it "ログインできること" do 
            post login_path, params: { user: user } 
            get "/users/#{user.id}"
            expect(response).to have_http_status :ok
        end 
      end 
    end 

    describe "#destroy" do 
        it "ログアウトできること" do 
          user = FactoryBot.create(:user) 

          # ログイン
          get login_path 
          post login_path params: { session: { email: user.email,
                                               password: user.password } } 
          user = User.last
          get "/users/#{user.id}"
          expect(response).to_not have_http_status :ok

          # ログアウト
          delete logout_path 
          get "/users/#{user.id}" 
          expect(response).to_not have_http_status :ok
        end 
    end 
end 