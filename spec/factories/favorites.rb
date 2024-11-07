FactoryBot.define do
  factory :favorite do
    association :article
    association :favorite_article_list
  end
end
