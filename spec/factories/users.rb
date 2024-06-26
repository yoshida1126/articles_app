FactoryBot.define do
  factory :user do
    name { "test user" } 
    email { "example@email.com" } 
    password { "test1111" }
    password_confirmation { "test1111" } 
  end
end
