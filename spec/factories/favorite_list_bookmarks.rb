FactoryBot.define do
  factory :favorite_list_bookmark do
    association :user
    association :favorite_article_list
  end
end
