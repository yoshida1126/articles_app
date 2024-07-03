require "rails_helper" 

RSpec.describe "Layouts", type: :system do 
    before do 
        driven_by(:rack_test) 
    end 
    let(:user) { FactoryBot.create(:user) } 

    describe "header" do
        context "as a logged in user" do 
            before do
                sign_in user 
                visit root_path 
            end 

            describe "Account" do 
                before do 
                    click_link "アカウント" 
                end 

                it "プロフィールをクリックするとプロフィールページに遷移すること" do 
                    click_link "プロフィール"
                    expect(page).to have_current_path "/users/#{user.id}"
                end 

                it "アカウント情報の編集をクリックすると編集ページに遷移すること" do 
                    click_link "アカウント情報の編集" 
                    expect(page).to have_current_path edit_user_path(user)
                end 

                it "ログアウトをクリックするとルートパスに遷移すること" do 
                    click_link "ログアウト" 
                    expect(page).to have_current_path root_path 
                end 

                it "ARTICLESをクリックするとルートパスに遷移すること" do
                    # rootに遷移することを確認するために編集ページに移動する
                    click_link "アカウント情報の編集" 
                    click_link "Articles" 
                    expect(page).to have_current_path root_path 
                end
            end
        end 

        context "as a non logged in user" do
            before do 
                visit root_path 
            end 

            it "ログインをクリックするとログインページに遷移すること" do 
                click_link "ログイン" 
                expect(page).to have_current_path login_path
            end 

            it "ARTICLESをクリックするとルートパスに遷移すること" do 
                # rootに遷移することを確認するために会員登録ページに移動する
                click_link "会員登録"
                click_link "Articles" 
                expect(page).to have_current_path root_path 
            end 
        end 
    end 

    describe "footer" do 
        context "as a logged in user" do 
            before do 
                sign_in (user) 
                visit root_path 
            end 

            it "Aboutをクリックするとアバウトページに遷移すること" do 
                click_link "About" 
                expect(page).to have_current_path about_path
            end 

            it "Helpをクリックするとヘルプページに遷移すること" do 
                click_link "Help" 
                expect(page).to have_current_path help_path 
            end 
        end 

        context "as a non logged in user" do 
            before do 
                visit root_path
            end 

            it "Aboutをクリックするとアバウトページに遷移すること" do 
                click_link "About" 
                expect(page).to have_current_path about_path
            end 

            it "Helpをクリックするとヘルプページに遷移すること" do 
                click_link "Help" 
                expect(page).to have_current_path help_path 
            end         
        end 
    end 
end 