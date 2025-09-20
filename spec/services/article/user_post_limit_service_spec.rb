require 'rails_helper'
require 'timecop'

RSpec.describe UserPostLimitService, type: :service do

    let(:user) { FactoryBot.create(:user) }
    let(:service) { UserPostLimitService.new(user) }
    let(:daily_limit) { described_class::DAILY_LIMIT }

    describe '#over_limit?' do
        before do
            $redis.flushdb

            @key = "user:#{user.id}:daily_posts:#{Date.today}"
        end

        it '制限値未満の場合はfalseが返ること(境界値 - 1)' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, daily_limit - 1)

                expect(service.over_limit?).to be false
            end
        end

        it '今回の投稿が制限値を超える場合はtrueが返ること(境界値)' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, daily_limit)

                expect(service.over_limit?).to be true
            end
        end
    end

    describe '#track_post' do
        before do
            $redis.flushdb

            @key = "user:#{user.id}:daily_posts:#{Date.today}"
        end

        it '制限値未満の場合は投稿後に本日の投稿数がインクリメントされていて、ttlが設定されていること' do
            
            # expire_if_neededはprivateメソッドであり、track_postからしか呼ばれないため、
            # このテストでは投稿数のインクリメントとあわせて、TTLの設定も確認している。

            Timecop.freeze(Time.now) do
                $redis.set(@key, 0)
                before_count = $redis.get(@key).to_i

                service.track_post

                after_count = $redis.get(@key).to_i
                ttl = $redis.ttl(@key)

                expect(after_count).to eq(before_count + 1)
                expect(ttl).to be > 0
            end
        end

        it '今回の投稿が制限値を超える場合は制限値自体が返ること' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, daily_limit)

                service.track_post

                after_count = $redis.get(@key).to_i

                expect(after_count).to eq(daily_limit)
            end
        end
    end

    describe '#current_count' do
        before do
            $redis.flushdb

            @key = "user:#{user.id}:daily_posts:#{Date.today}"
        end

        it '本日の投稿数が0の場合は0が返ること' do
            $redis.set(@key, 0)

            expect(service.current_count).to eq 0
        end

        it '本日の投稿数が返ること' do
            $redis.set(@key, daily_limit - 1)

            today_count = $redis.get(@key).to_i

            expect(service.current_count).to eq(today_count)
        end
    end
end