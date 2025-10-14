require 'rails_helper'

RSpec.describe TrendTagService, type: :service do

    describe '#call' do
        let(:user) { FactoryBot.create(:user) }

        context 'When there are five or more tags and ten or more articles with the tag' do

            before do
                tags = ['test1', 'test2', 'test3', 'test4', 'test5']
                tags.each do |tag|
                    10.times do
                        Article.create(draft: false, title: "test", content: "test", tag_list: tag, user_id: user.id)
                    end
                end
                trend_tags = ActsAsTaggableOn::Tag.joins(:taggings).distinct.most_used(5)
                service = described_class.new(trend_tags)
                @result_sections = service.call
            end

            it '返ってくるセクションが５つであること' do
                expect(@result_sections.size).to eq 5
            end

            it '事前に用意したタグごとの10件の記事が全部含まれること' do
                @result_sections.each do |section|
                    expect(section[:articles].count).to eq 10
                end
            end
        end

        context 'When only one tag is attached to 9 posts' do

            before do
                tags = ['test2', 'test3', 'test4', 'test5']
                9.times do
                    Article.create(draft: false, title: "test", content: "test", tag_list: "test1", user_id: user.id)
                end

                tags.each do |tag|
                    10.times do
                        Article.create(draft: false, title: "test", content: "test", tag_list: tag, user_id: user.id)
                    end
                end
                trend_tags = ActsAsTaggableOn::Tag.joins(:taggings).distinct.most_used(5)
                service = described_class.new(trend_tags)
                @result_sections = service.call
            end

            it '返ってくるセクションが４つであること' do
                expect(@result_sections.size).to eq 4
            end
        end
    end
end