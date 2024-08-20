require 'rails_helper'

RSpec.describe Like, type: :model do
    let(:like) { FactoryBot.create(:like) } 
    let(:other_like) { FactoryBot.build(:like) } 

  describe "validation" do 
    context "logged in user" do 
      it "いいねできること" do
        expect(like).to be_valid  
      end 

      it "ユーザーはひとつの記事にひとつしかいいねできないこと" do 
        other_like.user = like.user 
        other_like.article = like.article 
        expect(other_like).to_not be_valid 
      end 
    end 

    context "non logged in user" do 
      it "いいねできないこと" do 
        like.user = nil 
        expect(like).to_not be_valid 
      end 
    end 
  end 
end
