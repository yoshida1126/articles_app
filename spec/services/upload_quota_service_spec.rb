require 'rails_helper'

RSpec.describe UploadQuotaService, type: :service do
    let(:user) { FactoryBot.create(:user) }

    describe '#current' do
        context 'When type is :article' do
            let(:service) { described_class.new(user: user, type: :article) }

            before do
                $redis.flushdb

                @key = "upload_article_images_quota:#{user.id}:#{Date.today}"
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

        context 'When type is :comment' do
            let(:service) { described_class.new(user: user, type: :comment) }

            before do
                $redis.flushdb

                @key = "upload_comment_images_quota:#{user.id}:#{Date.today}"
            end

            it '本日のコメント画像未投稿の場合0が返ること' do
                Timecop.freeze(Time.now) do
                    result = service.current

                    expect(result).to eq 0
                end
            end

            it '本日投稿したコメント画像ファイルサイズが1MBの時は1が返ること' do
                Timecop.freeze(Time.now) do
                    $redis.set(@key, 1.megabytes)

                    result = service.current

                    expect(result).to eq 1.megabytes
                end
            end
        end
    end

    describe '#remaining' do
        context 'When type is :article' do
            let(:service) { described_class.new(user: user, type: :article) }

            before do
                $redis.flushdb

                @key = "upload_article_images_quota:#{user.id}:#{Date.today}"
            end

            it '本日の記事画像未投稿の場合5MBが返ること' do
                Timecop.freeze(Time.now) do
                    result = service.remaining

                    expect(result).to eq 5.megabytes
                end
            end

            it '本日投稿した記事画像のファイルサイズが4MBの時1MBが返ること' do
                Timecop.freeze(Time.now) do
                    $redis.set(@key, 4.megabytes)

                    result = service.remaining

                    expect(result).to eq 1.megabytes
                end
            end
        end

        context 'When type is :comment' do
            let(:service) { described_class.new(user: user, type: :comment) }

            before do
                $redis.flushdb

                @key = "upload_comment_images_quota:#{user.id}:#{Date.today}"
            end

            it '本日のコメント画像未投稿の場合2MBが返ること' do
                Timecop.freeze(Time.now) do
                    result = service.remaining

                    expect(result).to eq 2.megabytes
                end
            end

            it '本日投稿したコメント画像のファイルサイズが1MBの時1MBが返ること' do
                Timecop.freeze(Time.now) do
                    $redis.set(@key, 1.megabytes)

                    result = service.remaining

                    expect(result).to eq 1.megabytes
                end
            end
        end
    end

    describe '#remaining_mb' do
        context 'When type is :article' do
            let(:service) { described_class.new(user: user, type: :article) }

            before do
                $redis.flushdb

                @key = "upload_article_images_quota:#{user.id}:#{Date.today}"
            end

            it '本日の記事画像未投稿の場合5が返ること' do
                Timecop.freeze(Time.now) do
                    result = service.remaining_mb

                    expect(result).to eq 5
                end
            end

            it '本日投稿した記事画像のファイルサイズが4MBの時1が返ること' do
                Timecop.freeze(Time.now) do
                    $redis.set(@key, 4.megabytes)

                    result = service.remaining_mb

                    expect(result).to eq 1
                end
            end
        end

        context 'When type is :comment' do
            let(:service) { described_class.new(user: user, type: :comment) }

            before do
                $redis.flushdb

                @key = "upload_comment_images_quota:#{user.id}:#{Date.today}"
            end

            it '本日のコメント画像未投稿の場合2が返ること' do
                Timecop.freeze(Time.now) do
                    result = service.remaining_mb

                    expect(result).to eq 2
                end
            end

            it '本日投稿したコメント画像のファイルサイズが1MBの時1が返ること' do
                Timecop.freeze(Time.now) do
                    $redis.set(@key, 1.megabytes)

                    result = service.remaining_mb

                    expect(result).to eq 1
                end
            end
        end
    end

    describe '#track!' do
        context 'When type is :article and the total file size is within 5MB' do
            let(:service) { described_class.new(user: user, type: :article) }

            before do
                $redis.flushdb

                @key = "upload_article_images_quota:#{user.id}:#{Date.today}"
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

        context 'When type is :article and the total file size exceeds 5MB' do
            let!(:service) { described_class.new(user: user, type: :article) }

            before do
                $redis.flushdb

                @key = "upload_article_images_quota:#{user.id}:#{Date.today}"
            end

            it 'falseが返ること' do
                Timecop.freeze(Time.now) do
                    $redis.set(@key, 5.megabytes)
                    $redis.expire(@key, (Date.tomorrow.beginning_of_day - Time.current).to_i)
                    result = service.track!(1.megabytes)

                    expect(result).to be false
                end
            end
        end

        context 'When type is :comment and the total file size is within 2MB' do
            let(:service) { described_class.new(user: user, type: :comment) }

            before do
                $redis.flushdb

                @key = "upload_comment_images_quota:#{user.id}:#{Date.today}"
            end

            it 'trueが返ること' do
                Timecop.freeze(Time.now) do
                    result = service.track!(1.megabytes)

                    expect(result).to be true
                end
            end

            it '本日のコメント画像のファイルサイズがインクリメントされていて、ttlが設定されていること' do
                Timecop.freeze(Time.now) do
                    service.track!(1.megabytes)

                    result_mb = $redis.get(@key).to_i
                    ttl = $redis.ttl(@key)

                    expect(result_mb).to eq 1.megabytes
                    expect(ttl).to be > 0
                end
            end
        end

        context 'When the type is :comment and the total file size exceeds 2MB' do
            let(:service) { described_class.new(user: user, type: :comment) }

            before do
                $redis.flushdb

                @key = "upload_comment_images_quota:#{user.id}:#{Date.today}"
            end

            it 'falseが返ること' do
                Timecop.freeze(Time.now) do
                    $redis.set(@key, 2.megabytes)
                    $redis.expire(@key, (Date.tomorrow.beginning_of_day - Time.current).to_i)
                    result = service.track!(1.megabytes)

                    expect(result).to be false
                end
            end
        end
    end
end