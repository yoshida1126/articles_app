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

       it '最後にいいねしてから3秒以内だった場合falseが返ること' do
           Timecop.freeze(Time.now) do
               service.record_like_time
               expect(service.allowed?).to be false
            end
        end

        it '最後にいいねしてから3秒経っている場合はtrueが返ること' do
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

        it 'いいね直後は設定した制限時間を返すこと' do
            Timecop.freeze(Time.now) do
                service.record_like_time
                expect(service.remaining_time).to eq(rate_limit_seconds)
            end
        end

        it '2秒後は制限時間 - 2秒（誤差±1）を返すこと' do
            Timecop.freeze(Time.now) do
                service.record_like_time
            end

            Timecop.travel(2.seconds.from_now) do
                expect(service.remaining_time).to be_within(1).of(rate_limit_seconds - 2)
            end
        end

        it '3秒以上経っていれば0を返すこと' do
            Timecop.freeze(Time.now) do
                service.record_like_time
            end

            Timecop.travel(rate_limit_seconds + 1) do
                expect(service.remaining_time).to eq(0)
            end
        end

        it 'まだ一度もいいねしていない場合は0を返すこと' do
            expect(service.remaining_time).to eq(0)
        end
    end

    describe '#record_like_time' do
        let(:user) { FactoryBot.create(:user) }
        let(:comment) { FactoryBot.create(:article_comment) }
        let(:service) { described_class.new(user: user, article_comment: comment) }

        before { $redis.flushdb }

        it 'いいねした時間がRedisに記録されること' do
            Timecop.freeze(Time.now) do
                frozen_now = Time.now.to_i
                service.record_like_time
                stored_time = $redis.get("user:#{user.id}:like:comment:#{comment.id}").to_i
                expect(stored_time).to eq(frozen_now)
            end
        end
    end
end