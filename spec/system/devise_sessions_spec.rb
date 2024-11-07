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
            fill_in "メールアドレス", with: user.email 
            fill_in "パスワード", with: user.password 
            click_button "ログイン" 
            click_link 'プロフィール画像'

            expect(page).to_not have_link "ログイン", href: login_path 
            expect(page).to have_link "ログアウト", href: logout_path 
            expect(page).to have_link "プロフィール", href: user_path(user)  
        end 
    end 

    context "user login with invalid information" do 
        it "エラーメッセージが表示されること" do 
            visit login_path 
            fill_in "メールアドレス", with: "" 
            fill_in "パスワード", with: "" 
            click_button "ログイン" 
        
            expect(page).to have_selector "div.alert.alert-danger" 
            # flashが残っていないかのテスト 
            visit root_path 
            expect(page).to_not have_selector 'div.alert.alert-danger'
        end

        it "パスワードが間違っている場合エラーメッセージが表示されること" do
            visit login_path 
            fill_in "メールアドレス", with: user.email 
            fill_in "パスワード", with: "test" 
            click_button "ログイン" 

            expect(page).to have_selector "div.alert.alert-danger" 
            # flashが残っていないかのテスト
            visit root_path 
            expect(page).to_not have_selector 'div.alert.alert-danger' 
        end 
    end 
end

describe "#destroy" do 

  let(:user) { FactoryBot.create(:user) } 

  context "as a logged in user" do 
    before do 
        sign_in user 
        visit root_path
        click_link "プロフィール画像", match: :first, exact: true 
        click_link "ログアウト", match: :first, exact: true 
    end 

    it "ログアウトできること" do 
        expect(page).to_not have_content "プロフィール画像" 
        expect(page).to_not have_content "投　稿"
    end 
  end 
end 