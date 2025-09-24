require 'rails_helper'
require 'timecop'

RSpec.describe HeaderImageRateLimiterService, type: :service do

    let(:user) { FactoryBot.create(:user) }
    let(:daily_limit) { described_class::MAX_UPDATES_PER_DAY }

    describe '#exceeded?' do
        before do
            $redis.flushdb

            @key = "user:#{user.id}:header_image_update_count:#{Date.today}"
        end

        it '制限値未満の場合はfalseが返ること(境界値 - 1)' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, daily_limit - 1)

                expect(described_class.exceeded?(user.id, "test")).to be false
            end
        end

        it '今回の投稿が制限値を超える場合はtrueが返ること(境界値)' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, daily_limit)

                expect(described_class.exceeded?(user.id, "test")).to be true
            end
        end
    end

    describe '#current_count' do
        before do
            $redis.flushdb

            @key = "user:#{user.id}:header_image_update_count:#{Date.today}"
        end

        it '本日のヘッダー画像の変更回数が0の場合は0が返ること' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, 0)

                expect(described_class.count_for_today(user.id)).to eq 0
            end
        end

        it '本日のヘッダー画像変更回数が返ること' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, daily_limit - 1)

                today_count = $redis.get(@key).to_i

                expect(described_class.count_for_today(user.id)).to eq(today_count)
            end
        end
    end

    describe '#increment' do
        before do
            $redis.flushdb

            @key = "user:#{user.id}:header_image_update_count:#{Date.today}"
        end

        it '制限値未満の場合は本日のヘッダー画像更新回数がインクリメントされていること' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, 2)
                before_count = $redis.get(@key).to_i

                described_class.increment(user.id)

                after_count = $redis.get(@key).to_i

                expect(after_count).to eq(before_count + 1)
            end
        end
    end
end