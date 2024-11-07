FactoryBot.define do
  factory :article_comment do
    comment { "test comment" } 
    association :user 
    association :article 
    created_at { Time.zone.now } 
  end
end
