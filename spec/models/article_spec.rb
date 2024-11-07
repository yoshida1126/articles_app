require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:user) { FactoryBot.create(:user) } 
  let(:article) { FactoryBot.create(:article) }
  let!(:other_article) { FactoryBot.create(:other_article) }

  describe "association" do 
    it "ユーザーが削除されたら結びついている記事も削除されること" do 
      user = article.user 
      expect { 
        user.destroy
      }.to change(Article, :count).by -1 
    end 
  end 

  it "最も新しい投稿が順番的に最初に来ること" do 
    expect(article).to eq Article.first 
  end 

  describe "validation" do 
    context "with valid attributes" do 
      it "バリデーションが通ること" do 
        expect(article).to be_valid 
      end

      it "50文字のタイトルでバリデーションが通ること(境界値)" do 
        article.title = "a" * 50 
        expect(article).to be_valid 
      end 
    end 

    context "with invalid attributes" do 
      it "ユーザーidがないとバリデーションが通らないこと" do 
        article.user_id = nil 
        expect(article).to_not be_valid 
      end 

      it "タイトルがないとバリデーションが通らないこと" do 
        article.title = nil 
       expect(article).to_not be_valid 
      end 

      it "タイトルが51文字以上だとバリデーションが通らないこと" do 
        article.title = "a" * 51 
        expect(article).to_not be_valid 
      end 

      it "contentがないとバリデーションが通らないこと" do 
        article.content = "" 
        expect(article).to_not be_valid
      end 
    end 
  end 
end
