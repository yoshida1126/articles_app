require "rails_helper" 

RSpec.describe "Users", type: :system do 
    before do 
        driven_by(:rack_test) 
    end 

    describe "#create" do 

      context "with valid information" do 
        it "成功時のメッセージが表示されること" do 
            valid_user_params = FactoryBot.attributes_for(:user) 

            visit sign_up_path 
            fill_in "Name", with: valid_user_params[:name] 
            fill_in "Email", with: valid_user_params[:email] 
            fill_in "Password", with: valid_user_params[:password] 
            fill_in "Confirmation", with: valid_user_params[:password_confirmation] 
            click_button "登　録" 

            expect(page).to have_selector "div.alert-success"
        end 
      end 

      context "with invalid information" do 
        it "エラーメッセージが表示されること" do 
          visit sign_up_path 
          fill_in "Name", with: "" 
          fill_in "Email", with: "example@invalid" 
          fill_in "Password", with: "test" 
          fill_in "Confirmation", with: "tes" 
          click_button "登　録" 

          expect(page).to have_selector "div#error_explanation" 
          expect(page).to have_selector "div.alert-danger" 
        end 
      end 
    end
end 