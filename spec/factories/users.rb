FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "test user #{n}" } 
    sequence(:email) { |n| "example-#{n}@email.com" } 
    password { "test1111" }
    password_confirmation { "test1111" } 
    confirmed_at { Time.now }
  end

  factory :other_user, class: User do 
    name { "other user" } 
    email { "other@example.com" } 
    password { "other1111" }
    password_confirmation { "other1111" } 
    confirmed_at { Time.now }
  end 

  factory :invalid_user, class: User do 
    name { "" }
    email { "address@invalid" } 
    password { "test" } 
    password_confirmation { "test" } 
  end 
end
