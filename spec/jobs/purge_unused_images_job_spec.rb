require 'rails_helper'

RSpec.describe PurgeUnusedImagesJob, type: :job do
  describe '#perform' do
    let(:target_time) { 1.day.ago }

    let!(:target_blob) do
      FactoryBot.create(:active_storage_blob).tap do |blob|
        blob.update!(created_at: target_time.to_time)
      end
    end

    let!(:attached_blob) do
      article = FactoryBot.create(:article)
      blob = FactoryBot.create(:active_storage_blob)

      article.image.attach(blob)

      blob.update!(created_at: target_time.to_time)
      blob
    end

    let!(:today_blob) do
      FactoryBot.create(:active_storage_blob, created_at: Time.current)
    end

    let!(:old_blob) do
      FactoryBot.create(:active_storage_blob).tap do |blob|
        blob.update!(created_at: 2.days.ago)
      end
    end

    it '1日前に作成された未添付のBlobのみが削除されること' do
      expect {
        PurgeUnusedImagesJob.new.perform
      }.to change { ActiveStorage::Blob.count }.by(-1)

      expect(ActiveStorage::Blob.exists?(target_blob.id)).to be_falsey
      
      expect(ActiveStorage::Blob.exists?(attached_blob.id)).to be_truthy
      expect(ActiveStorage::Blob.exists?(today_blob.id)).to be_truthy
      expect(ActiveStorage::Blob.exists?(old_blob.id)).to be_truthy
    end
  end
end
