require 'rails_helper'

RSpec.describe UploadQuotaService, type: :service do
    let(:user) { FactoryBot.create(:user) }

    describe '#current' do
        let(:service) { described_class.new(user: user) }

        before do
            $redis.flushdb

            @key = "upload_images_quota:#{user.id}:#{Date.today}"
        end

        it '本日の記事画像未投稿の場合0が返ること' do
            Timecop.freeze(Time.now) do
                result = service.current

                expect(result).to eq 0
            end
        end

        it '本日投稿した記事の画像ファイルサイズが4MBの時は4が返ること' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, 4.megabytes)

                result = service.current

                expect(result).to eq 4.megabytes
            end
        end
    end

    describe '#remaining' do
        let(:service) { described_class.new(user: user) }

        before do
            $redis.flushdb

            @key = "upload_images_quota:#{user.id}:#{Date.today}"
        end

        it '本日の記事画像未投稿の場合10MBが返ること' do
            Timecop.freeze(Time.now) do
                result = service.remaining

                expect(result).to eq 10.megabytes
            end
        end

        it '本日投稿した記事画像のファイルサイズが4MBの時6MBが返ること' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, 4.megabytes)

                result = service.remaining

                expect(result).to eq 6.megabytes
            end
        end
    end

    describe '#remaining_mb' do
        let(:service) { described_class.new(user: user) }

        before do
            $redis.flushdb

            @key = "upload_images_quota:#{user.id}:#{Date.today}"
        end

        it '本日の記事画像未投稿の場合10が返ること' do
            Timecop.freeze(Time.now) do
                result = service.remaining_mb

                expect(result).to eq 10
            end
        end

        it '本日投稿した記事画像のファイルサイズが4MBの時6が返ること' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, 4.megabytes)

                result = service.remaining_mb

                expect(result).to eq 6
            end
        end
    end

    describe '#track!' do
        context 'When the total file size is within 10MB' do
            let(:service) { described_class.new(user: user) }

            before do
                $redis.flushdb

                @key = "upload_images_quota:#{user.id}:#{Date.today}"
            end

            it 'trueが返ること' do
                Timecop.freeze(Time.now) do
                    result = service.track!(1.megabytes)

                    expect(result).to be true
                end
            end

            it '本日の記事画像のファイルサイズがインクリメントされていて、ttlが設定されていること' do
                Timecop.freeze(Time.now) do
                    service.track!(1.megabytes)

                    result_mb = $redis.get(@key).to_i
                    ttl = $redis.ttl(@key)

                    expect(result_mb).to eq 1.megabytes
                    expect(ttl).to be > 0
                end
            end
        end

        context 'When the total file size exceeds 10MB' do
            let!(:service) { described_class.new(user: user) }

            before do
                $redis.flushdb

                @key = "upload_images_quota:#{user.id}:#{Date.today}"
            end

            it 'falseが返ること' do
                Timecop.freeze(Time.now) do
                    $redis.set(@key, 10.megabytes)
                    $redis.expire(@key, (Date.tomorrow.beginning_of_day - Time.current).to_i)
                    result = service.track!(1.megabytes)

                    expect(result).to be false
                end
            end
        end
    end
end