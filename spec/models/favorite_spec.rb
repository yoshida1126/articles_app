require 'rails_helper'

RSpec.describe Favorite, type: :model do
  describe "validation" do 
    let(:favorite) { FactoryBot.create(:favorite) }

    context "with invalid attributes" do 
      it "is invalid without a article_id" do 
        favorite.article = nil 
        expect(favorite).to_not be_valid
      end

      it "is invalid without a favorite_article_list_id" do 
        favorite.favorite_article_list = nil 
        expect(favorite).to_not be_valid
      end 
    end
  end
end
