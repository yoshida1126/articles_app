FactoryBot.define do
  factory :favorite_article_list do
    list_title { "Test" }
    association :user
    created_at { Time.zone.now } 

    trait :with_favorites do 
      after(:create) do |favorite_article_list| 
        article = FactoryBot.create(:article) 
        favorite_article_list.favorite(article) 
      end 
    end 
  end
end
