FactoryBot.define do
  factory :article do
    title { 'Test article' }
    content { 'article' }
    association :user
    created_at { Time.zone.now }
    tag_list { 'article' }
  end

  factory :other_article, class: Article do
    title { 'Other article' }
    content { 'oter test' }
    association :user
    created_at { 30.minutes.ago }
    tag_list { 'article' }
  end
end
