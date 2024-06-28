require 'rails_helper' 

RSpec.describe "Sessions", type: :system do 
    before do 
        driven_by(:rack_test)
    end 
end 

describe "#create" do 

    let(:user) { FactoryBot.create(:user) } 

    context "user login with valid information" do 

        it "ヘッダーにログインリンクがなく、ログアウトリンク、プロフィールリンクがあること" do 
            visit login_path 
            fill_in "Email", with: user.email 
            fill_in "Password", with: user.password 
            click_button "ログイン" 
            click_on 'アカウント'

            expect(page).to_not have_link "ログイン", href: login_path 
            expect(page).to have_link "ログアウト", href: logout_path 
            expect(page).to have_link "プロフィール", href: user_path(user)  
        end 
    end 

    context "user login with invalid information" do 
        it "エラーメッセージが表示されること" do 
            visit login_path 
            fill_in "Email", with: "" 
            fill_in "Password", with: "" 
            click_button "ログイン" 
        
            expect(page).to have_selector "div.alert.alert-danger" 
            # flashが残っていないかのテスト 
            visit root_path 
            expect(page).to_not have_selector 'div.alert.alert-danger'
        end

        it "パスワードが間違っている場合エラーメッセージが表示されること" do
            visit login_path 
            fill_in "Email", with: user.email 
            fill_in "Password", with: "test" 
            click_button "ログイン" 

            expect(page).to have_selector "div.alert.alert-danger" 
            # flashが残っていないかのテスト
            visit root_path 
            expect(page).to_not have_selector 'div.alert.alert-danger' 
        end 
    end 
end