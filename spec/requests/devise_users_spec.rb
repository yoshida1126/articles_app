RSpec.describe "Users", type: :request do 

    describe "#create" do 

      let(:valid_user_params) { FactoryBot.attributes_for(:user) }

      context "with valid information" do
        it "登録できること" do 
          get sign_up_path 
          expect {
            post sign_up_path, params: { user: valid_user_params }
        }.to change(User, :count).by 1 
        end 

        it "登録後ホームページにリダイレクトされること" do 
          post sign_up_path, params: { user: valid_user_params } 
          expect(response).to redirect_to root_path 
        end 
      end 

      context "with invalid information" do 
        it "登録できないこと" do
          get sign_up_path 
          expect {
              post sign_up_path, params: { user: { name: "", 
                                                  email: "test@invalid",
                                                  password: "test",
                                                  password_confirmation: "" } }
          }.to_not change(User, :count)
        end 
      end 
    end 
end 