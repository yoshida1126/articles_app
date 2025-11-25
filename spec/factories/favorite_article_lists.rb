FactoryBot.define do
  factory :favorite_article_list do
    list_title { 'Test' }
    association :user
    created_at { Time.zone.now }

    transient do
      articles_count { 1 }
    end

    after(:create) do |favorite_article_list, evaluator|
      evaluator.articles_count.times do
        article = FactoryBot.create(:article, user: favorite_article_list.user)
        favorite_article_list.favorite(article)
        favorite_article_list.save!
      end
    end
  end
end
