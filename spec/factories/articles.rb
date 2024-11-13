FactoryBot.define do
  factory :article do
    title { 'Test article' }
    content { 'test' }
    association :user
    created_at { Time.zone.now }
    tag_list { 'test' }
  end

  factory :other_article, class: Article do
    title { 'Other article' }
    content { 'oter test' }
    association :user
    created_at { 30.minutes.ago }
    tag_list { 'test' }
  end
end
