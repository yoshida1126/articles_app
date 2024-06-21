require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ユーザー登録' do 

    let (:user) { FactoryBot.build(:user) }

    it "メールアドレスは小文字で保存されること" do 
      mixed_case_email = "Foo@ExAmPle.coM" 
      user.email = mixed_case_email 
      user.save 
      expect(mixed_case_email.downcase).to eq user.reload.email 
    end 

    context "with valid attributes" do 

      it "name, email, password, password_confirmationが存在すれば登録できること" do 
        expect(user).to be_valid 
      end 

      it "メールアドレスのフォーマットが正しければ登録できること" do
        valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
          first.last@foo.jp alice+bob@baz.cn] 
        valid_addresses.each do |valid_address| 
          user.email = valid_address 
          expect(user).to be_valid 
        end 
      end 
    end

    context "with invalid attributes" do 

      it "nameが空欄では登録できないこと" do
        user.name = ""
        expect(user).to_not be_valid
      end 

      it "emailが空欄では登録できないこと" do 
        user.email = "" 
        expect(user).to_not be_valid 
      end 

      it "nameは長すぎると登録できないこと" do 
        user.name = "a" * 51 
        expect(user).to_not be_valid 
      end 

      it "emailは長すぎると登録できないこと" do 
        user.email = "a" * 244 + "@example.com" 
        expect(user).to_not be_valid
      end 

      it "メールアドレスのフォーマットが無効な場合は登録できないこと" do 
        invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. 
          foo@bar_baz.com foo@bar+baz.com]
        invalid_addresses.each do |invalid_address| 
          user.email = invalid_address 
          expect(user).to_not be_valid 
        end 
      end 

      it "メールアドレスがすでに登録されている場合はそのメールアドレスは無効になること" do 
        duplicate_user = user.dup 
        duplicate_user.email = user.email.upcase 
        user.save 
        expect(duplicate_user).to_not be_valid
      end

      it "パスワードが空欄だと登録できないこと" do 
        user.password = user.password_confirmation = " " * 6 
        expect(user).not_to be_valid 
      end 

      it "パスワードが短すぎると登録できないこと" do 
        user.password = user.password_confirmation = "abcde" 
        expect(user).not_to be_valid 
      end 
    end 
  end
end
