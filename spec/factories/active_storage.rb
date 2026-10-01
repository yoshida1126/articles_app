FactoryBot.define do
  factory :active_storage_blob, class: 'ActiveStorage::Blob' do
    initialize_with do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join('spec/fixtures/map.png')),
        filename: 'map.png',
        content_type: 'image/png'
      )
    end
  end
end