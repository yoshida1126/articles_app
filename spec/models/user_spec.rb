require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'user registration' do
    let(:user) { FactoryBot.build(:user) }

    it 'saves the email address in lowercase' do
      mixed_case_email = 'Foo@ExAmPle.coM'
      user.email = mixed_case_email
      user.save
      expect(mixed_case_email.downcase).to eq user.reload.email
    end

    context 'with valid attributes' do
      it 'is valid with a name, email, password, and password confirmation' do
        expect(user).to be_valid
      end

      it 'is valid with a properly formatted email address' do
        valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                             first.last@foo.jp alice+bob@baz.cn]
        valid_addresses.each do |valid_address|
          user.email = valid_address
          expect(user).to be_valid
        end
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without a name' do
        user.name = ''
        expect(user).to_not be_valid
      end

      it 'is invalid without an email address' do
        user.email = ''
        expect(user).to_not be_valid
      end

      it 'is invalid with a name longer than 50 characters' do
        user.name = 'a' * 51
        expect(user).to_not be_valid
      end

      it 'is invalid with an email address longer than 255 characters' do
        user.email = 'a' * 244 + '@example.com'
        expect(user).to_not be_valid
      end

      it 'is invalid with an improperly formatted email address' do
        invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                               foo@bar_baz.com foo@bar+baz.com]
        invalid_addresses.each do |invalid_address|
          user.email = invalid_address
          expect(user).to_not be_valid
        end
      end

      it 'is invalid when the email address is already registered' do
        duplicate_user = user.dup
        duplicate_user.email = user.email.upcase
        user.save
        expect(duplicate_user).to_not be_valid
      end

      it 'is invalid with a blank password' do
        user.password = user.password_confirmation = ' ' * 6
        expect(user).not_to be_valid
      end

      it 'is invalid with a password shorter than 6 characters' do
        user.password = user.password_confirmation = 'abcde'
        expect(user).not_to be_valid
      end
    end
  end

  describe '#follow and #unfollow' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    it 'can follow the other user' do
      expect(user.following?(other_user)).to_not be_truthy
      user.follow(other_user)
      expect(user.following?(other_user)).to be_truthy
      expect(other_user.followers.include?(user)).to be_truthy
    end

    it 'can unfollow the other user' do
      user.follow(other_user)
      expect(user.following?(other_user)).to be_truthy
      user.unfollow(other_user)
      expect(user.following?(other_user)).to_not be_truthy
    end
  end

  describe '#feed' do
    let(:user) { FactoryBot.create(:user, :with_articles) }
    let(:user_following) { FactoryBot.create(:user, :with_articles) }
    let(:user_unfollowed) { FactoryBot.create(:user, :with_articles) }
    before do
      user.follow(user_following)
    end

    it 'includes the user’s own articles in the feed' do
      user.articles.each do |article_self|
        expect(user.feed).to be_include(article_self)
      end
    end

    it 'includes articles from followed users in the feed' do
      user_following.articles.each do |article_following|
        expect(user.feed).to be_include(article_following)
      end
    end

    it 'does not include articles from unfollowed users in the feed' do
      user_unfollowed.articles.each do |article_unfollowed|
        expect(user.feed).to_not be_include(article_unfollowed)
      end
    end
  end
end
