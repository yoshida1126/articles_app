require 'rails_helper'

RSpec.describe UploadQuotaService, type: :service do
    let(:user) { FactoryBot.create(:user) }

    describe '#current' do
        let(:service) { described_class.new(user: user) }

        before do
            $redis.flushdb

            @key = "upload_images_quota:#{user.id}:#{Date.today}"
        end

        it 'returns 0 when no article images have been uploaded today' do
            Timecop.freeze(Time.now) do
                result = service.current

                expect(result).to eq 0
            end
        end

        it 'returns 4 MB when 4 MB worth of article images have been uploaded today' do
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

        it 'returns 10 MB when no article images have been uploaded today' do
            Timecop.freeze(Time.now) do
                result = service.remaining

                expect(result).to eq 10.megabytes
            end
        end

        it 'returns 6 MB when 4 MB worth of article images have been uploaded today' do
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

        it 'returns 10 when no article images have been uploaded today' do
            Timecop.freeze(Time.now) do
                result = service.remaining_mb

                expect(result).to eq 10
            end
        end

        it 'returns 6 when 4 MB worth of article images have been uploaded today' do
            Timecop.freeze(Time.now) do
                $redis.set(@key, 4.megabytes)

                result = service.remaining_mb

                expect(result).to eq 6
            end
        end
    end

    describe '#track!' do
        context 'when the total file size is within 10 MB' do
            let(:service) { described_class.new(user: user) }

            before do
                $redis.flushdb

                @key = "upload_images_quota:#{user.id}:#{Date.today}"
            end

            it 'returns true' do
                Timecop.freeze(Time.now) do
                    result = service.track!(1.megabytes)

                    expect(result).to be true
                end
            end

            it 'increments the uploaded article image file size and sets a TTL' do
                Timecop.freeze(Time.now) do
                    service.track!(1.megabytes)

                    result_mb = $redis.get(@key).to_i
                    ttl = $redis.ttl(@key)

                    expect(result_mb).to eq 1.megabytes
                    expect(ttl).to be > 0
                end
            end
        end

        context 'when the total file size exceeds 10 MB' do
            let!(:service) { described_class.new(user: user) }

            before do
                $redis.flushdb

                @key = "upload_images_quota:#{user.id}:#{Date.today}"
            end

            it 'returns false' do
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