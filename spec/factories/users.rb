FactoryBot.define do
  factory :user, aliases: [:followed, :follower] do
    sequence(:name) { |n| "test user #{n}" } 
    sequence(:email) { |n| "example-#{n}@email.com" } 
    password { "test1111" }
    password_confirmation { "test1111" } 
    confirmed_at { Time.now }
    after(:build) do |user| 
      user.profile_img.attach(io: File.open('spec/fixtures/profile.jpg'), filename: 'profile.jpg', content_type: 'image/jpeg')
    end 

    trait :with_relationships do 
      after(:create) do |user| 
        30.times do 
          other_user = create(:user) 
          user.follow(other_user) 
          other_user.follow(user) 
        end 
      end 
    end 

    trait :with_articles do 
      after(:create) { |user| create_list(:article, 5, user: user) } 
    end 

    trait :with_favorite_article_lists do 
      after(:create) { |user| create_list(:favorite_article_list, 1, user: user) }
    end 
  end

  factory :other_user, class: User do 
    name { "other user" } 
    email { "other@example.com" } 
    password { "other1111" }
    password_confirmation { "other1111" } 
    confirmed_at { Time.now }
    after(:build) do |other_user| 
      other_user.profile_img.attach(io: File.open('spec/fixtures/profile.jpg'), filename: 'profile.jpg', content_type: 'image/jpeg')
    end 
  end 

  factory :invalid_user, class: User do 
    name { "" }
    email { "address@invalid" } 
    password { "test" } 
    password_confirmation { "test" } 
  end 
end
