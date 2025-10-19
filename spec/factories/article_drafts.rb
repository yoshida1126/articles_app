FactoryBot.define do
  factory :article_draft do
    title { 'Test article' }
    content { 'article' }
    association :user
    created_at { Time.zone.now }
    tag_list { 'article' }
    editing { true }
  end
end
