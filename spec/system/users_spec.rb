require 'rails_helper' 

RSpec.describe "Users", type: :system do 
    before do 
        driven_by(:rack_test)
    end 
end 

describe "GET /users/id" do 
    describe "following and followers" do 
        let(:user_with_relationships) { FactoryBot.create(:user, :with_relationships) } 
        let(:following) { user_with_relationships.following.count } 
        let(:followers) { user_with_relationships.followers.count } 

        it "プロフィールページにフォローとフォロワーの統計が表示されていること" do 
          sign_in user_with_relationships 
          visit root_path 
          click_link "プロフィール画像", match: :first, exact: true 
          click_link "プロフィール", match: :first, exact: true 
          expect(page).to have_content("#{following}\nフォロー")
          expect(page).to have_content("#{followers}\nフォロワー")
        end 
    end 
end 

describe "GET /users/id/following" do 
    let(:user) { FactoryBot.create(:user) } 

    context "as a logged in user" do 
        before do 
            @user_with_relationships = FactoryBot.create(:user, :with_relationships)
            @following = @user_with_relationships.following 
            sign_in @user_with_relationships 
        end 

        it "フォローしたユーザーの人数が正しく表示されていること" do 
            visit following_user_path(@user_with_relationships) 

            expect(@following).to_not be_empty 

            expect(page).to have_content("#{@following.count}\nフォロー")
            @following.paginate(page: 1, per_page: 15).each do |follow| 
                expect(page).to have_link follow.name, href: "/users/#{follow.id}"
            end 
        end 
    end 

    context "as a non-logged in user" do 
        it "ログインページにリダイレクトされること" do 
            get following_user_path(user) 
            expect(response).to redirect_to login_path 
        end 
    end 
end 

describe "GET /users/id/followers" do 
    let(:user) { FactoryBot.create(:user) } 

    context "as a logged in user" do 
        before do 
            @user_with_relationships = FactoryBot.create(:user, :with_relationships) 
            @followers = @user_with_relationships.followers 
            sign_in @user_with_relationships 
        end 

        it "フォロワーの人数が正しく表示されていること" do 
            visit followers_user_path(@user_with_relationships) 

            expect(@followers).to_not be_empty 

            expect(page).to have_content("#{@followers.count}\nフォロワー")
            @followers.paginate(page: 1, per_page: 15).each do |follower| 
                expect(page).to have_link follower.name, href: "/users/#{follower.id}"
            end 
        end 
    end 

    context "as a non-logged in user" do 
        it "ログインページにリダイレクトされること" do 
            get followers_user_path(user) 
            expect(response).to redirect_to login_path 
        end 
    end 
end 