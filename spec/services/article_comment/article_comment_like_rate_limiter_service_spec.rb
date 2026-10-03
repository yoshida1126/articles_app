require 'rails_helper'
require 'timecop'

RSpec.describe ArticleCommentLikeRateLimiterService, type: :service do

    describe '#allowed?' do
        let(:user) { FactoryBot.create(:user) }
        let(:comment) { FactoryBot.create(:article_comment) }
        let(:service) { described_class.new(user: user, article_comment: comment) }
        let(:rate_limit_seconds) { described_class::RATE_LIMIT_SECONDS }

        before do
            $redis.flushdb
        end

       it 'returns false when less than 3 seconds have passed since the last like' do
           Timecop.freeze(Time.now) do
               service.record_like_time
               expect(service.allowed?).to be false
            end
        end

        it 'returns true when 3 seconds have passed since the last like' do
            Timecop.freeze(Time.now) do
                service.record_like_time
            end
 
            Timecop.travel(rate_limit_seconds + 1) do
                expect(service.allowed?).to be true
            end
        end
    end

    describe '#remaining_time' do
        let(:user) { FactoryBot.create(:user) }
        let(:comment) { FactoryBot.create(:article_comment) }
        let(:service) { described_class.new(user: user, article_comment: comment) }
        let(:rate_limit_seconds) { described_class::RATE_LIMIT_SECONDS }

        before { $redis.flushdb }

        it 'returns the configured rate limit duration immediately after liking' do
            Timecop.freeze(Time.now) do
                service.record_like_time
                expect(service.remaining_time).to eq(rate_limit_seconds)
            end
        end

        it 'returns the remaining time minus 2 seconds after 2 seconds have passed, with a tolerance of ±1 second' do
            Timecop.freeze(Time.now) do
                service.record_like_time
            end

            Timecop.travel(2.seconds.from_now) do
                expect(service.remaining_time).to be_within(1).of(rate_limit_seconds - 2)
            end
        end

        it 'returns 0 when 3 seconds or more have passed' do
            Timecop.freeze(Time.now) do
                service.record_like_time
            end

            Timecop.travel(rate_limit_seconds + 1) do
                expect(service.remaining_time).to eq(0)
            end
        end

        it 'returns 0 when the user has never liked a comment' do
            expect(service.remaining_time).to eq(0)
        end
    end

    describe '#record_like_time' do
        let(:user) { FactoryBot.create(:user) }
        let(:comment) { FactoryBot.create(:article_comment) }
        let(:service) { described_class.new(user: user, article_comment: comment) }

        before { $redis.flushdb }

        it 'records the like timestamp in Redis' do
            Timecop.freeze(Time.now) do
                frozen_now = Time.now.to_i
                service.record_like_time
                stored_time = $redis.get("user:#{user.id}:like:comment:#{comment.id}").to_i
                expect(stored_time).to eq(frozen_now)
            end
        end
    end
end