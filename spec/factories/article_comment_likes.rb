FactoryBot.define do
  factory :article_comment_like do
    association :user
    association :article_comment
  end
end
