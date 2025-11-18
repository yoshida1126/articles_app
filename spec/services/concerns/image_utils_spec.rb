require 'rails_helper'

RSpec.describe ImageUtils do
    include ImageUtils

    describe '#resize_article_header_image' do
        let(:dummy_tempfile) { Tempfile.new(['dummy', '.jpg']) }
        let(:image) do
            double('image',
            tempfile: dummy_tempfile,
            original_filename: 'test.jpg',
            content_type: 'image/jpeg'
           )
        end

        it '返り値が UploadedFile のインスタンスであること' do
            mock_proc = Proc.new { |tempfile| tempfile }  # 実際のリサイズ処理をモック

            result = resize_article_header_image(image, processor_proc: mock_proc)

            expect(result).to be_an_instance_of(ActionDispatch::Http::UploadedFile)
        end

        it 'ヘッダー画像がアップロードされていない場合はnilが返ること' do
            image = nil
            expect(resize_article_header_image(image)).to eq nil
        end
    end

    describe '#attach_images_to_resource' do
        # モックの blob
        let(:mock_blob) { instance_double('ActiveStorage::Blob') }
        # blob_finderがblob_keyで呼ばれたら、mock_blobを返すようにする
        let(:blob_finder) { ->(key) { mock_blob } }
        # resource側も attach を spy できるようにモック化
        let(:mock_resource) do
            double('Resource').tap do |resource|
                allow(resource).to receive(:attach)
            end
        end

        it 'used_blob_signed_idsのblobがリソースにアタッチされること' do
            # 対象のメソッドを呼び出し
            attach_images_to_resource(mock_resource, ['abc123'], blob_finder: blob_finder)
            # attachが呼ばれたことを確認
            expect(mock_resource).to have_received(:attach).with(mock_blob)
        end

        it 'used_blob_signed_idsが空の場合nilが返ること' do
            expect(attach_images_to_resource(mock_resource, [], blob_finder: blob_finder)).to eq nil
        end
    end

    describe '#extract_s3_urls' do
        it 'URLが含まれていれば正しく抽出する' do
            content = "画像はこちら → rails/active_storage/blobs/abc123/file.png"
            expect(extract_s3_urls(content)).to eq(["rails/active_storage/blobs/abc123/file.png"])
        end

        it '複数のURLがあればすべて抽出する' do
            content = <<~TEXT
                1枚目の画像
                rails/active_storage/blobs/abc123/file1.png
                2枚目の画像
                rails/active_storage/blobs/def456/file2.jpg
            TEXT
            expect(extract_s3_urls(content)).to match_array([
                "rails/active_storage/blobs/abc123/file1.png",
                "rails/active_storage/blobs/def456/file2.jpg"
            ])
        end

        it 'URLがなければ空の配列を返す' do
            content = "これはただのテキストです"
            expect(extract_s3_urls(content)).to eq([])
        end
    end

    describe '#get_blob_signed_ids' do
        # blob_finderがblob_keyで呼ばれたら、mock_blobを返すようにする
        let(:blob_finder) do
            ->(key) {
                case key
                when 'abc123' then mock_blob1
                when 'def123' then mock_blob2
                else
                    nil
                end
            }
        end
        # モックの blob
        let(:mock_blob1) do
          instance_double('ActiveStorage::Blob', signed_id: 'abc123')
        end       
        let(:mock_blob2) do
          instance_double('ActiveStorage::Blob', signed_id: 'def123')
        end

        it '記事内で使われる画像のsigned_idの配列が返ってくること' do
            image_urls = [
                'rails/active_storage/blobs/abc123/file1.png',
                'rails/active_storage/blobs/def123/file1.png'
            ]
            expect(get_blob_signed_id_from_url(
                image_urls,
                blob_finder: blob_finder
            )).to match_array(['abc123', 'def123'])
        end

        it 'image_urlsが空の場合、空配列[]が返ること' do
            image_urls = []
            expect(get_blob_signed_id_from_url(
                image_urls,
                blob_finder: blob_finder
            )).to match_array([])
        end
    end

    describe '#calculate_unused_blob_signed_ids' do
        # このメソッドは、記事本文内でアップロードされた画像の signed_ids のうち、
        # 実際に本文などで使用されていない(使用されなくなった)未使用の signed_id を特定するためのメソッド。
        # attached_signed_ids(すでに記事本文内で使われていた画像のsinged_id) がある場合は、それを含めた全体から used_blob_signed_ids を引いたものを返す。

        it '記事本文から元々使われていた画像URLと新しく追加された画像URLが消されていない場合、空配列が返されること' do
            blob_signed_ids = ['ABC123']
            attached_signed_ids = ['DEF123']
            used_blob_signed_ids = ['ABC123', 'DEF123']
            expect(calculate_unused_blob_signed_ids(
                blob_signed_ids,
                attached_signed_ids,
                used_blob_signed_ids
            )).to eq([])
        end

        it '記事本文からアップロードした画像のURLを消した場合、その画像のsigned_idを含む配列が返されること' do
            blob_signed_ids = ['ABC123']
            attached_signed_ids = ['DEF123']
            used_blob_signed_ids = ['DEF123']
            expect(calculate_unused_blob_signed_ids(
                blob_signed_ids,
                attached_signed_ids,
                used_blob_signed_ids
            )).to eq(['ABC123'])
        end

        it '記事本文から元々使われていた画像URLを消した場合、その画像のsigned_idを含む配列が返されること' do
            blob_signed_ids = ['ABC123']
            attached_signed_ids = ['DEF123']
            used_blob_signed_ids = ['ABC123']
            expect(calculate_unused_blob_signed_ids(
                blob_signed_ids,
                attached_signed_ids,
                used_blob_signed_ids
            )).to eq(['DEF123'])
        end

        it '記事本文から元々使われていた画像URLと新しく追加された画像URLが全部消されていた場合、それらの画像のsigned_idを含む配列が返されること' do
            blob_signed_ids = ['ABC123']
            attached_signed_ids = ['DEF123']
            used_blob_signed_ids = []
            expect(calculate_unused_blob_signed_ids(
                blob_signed_ids,
                attached_signed_ids,
                used_blob_signed_ids
            )).to match_array(['ABC123', 'DEF123'])
        end

        it 'blob_signed_idsが空で、attached_signed_idsだけに値がある場合、attached_signed_idsが返されること' do
            blob_signed_ids = []
            attached_signed_ids = ['DEF123']
            used_blob_signed_ids = []
            expect(calculate_unused_blob_signed_ids(
                blob_signed_ids,
                attached_signed_ids,
                used_blob_signed_ids
            )).to eq(['DEF123'])
        end

        it 'blob_signed_idsとattached_signed_idsの両方が空の場合、空の配列が返されること' do
            blob_signed_ids = []
            attached_signed_ids = []
            used_blob_signed_ids = []
            expect(calculate_unused_blob_signed_ids(
                blob_signed_ids,
                attached_signed_ids,
                used_blob_signed_ids
            )).to eq([])
        end
    end

    describe '#unused_blob_delete' do
        # blob_finderがblob_keyで呼ばれたら、mock_blobを返すようにする
        let(:blob_finder) do
            ->(key) {
                case key
                when 'abc123' then mock_blob1
                when 'def123' then mock_blob2
                else
                    nil
                end
            }
        end
        # モックの blob
        let(:mock_blob1) do
            instance_double('ActiveStorage::Blob', id: 1, signed_id: 'abc123').tap do |blob|
                allow(blob).to receive(:purge_later)
            end
        end       
        let(:mock_blob2) do
            instance_double('ActiveStorage::Blob', id: 2, signed_id: 'def123').tap do |blob|
                allow(blob).to receive(:purge_later)
            end
        end

        # attachments_finderがidで呼ばれたら、mock_attachmentsを返すようにする
        let(:attachments_finder) do
            ->(id) {
                case id
                when 1 then attachments1
                when 2 then attachments2
                else
                    nil
                end
            }
        end

        # モックの attachment
        let(:mock_attachments1) do
            instance_double('ActiveStorage::Attachment', signed_id: 'abc123').tap do |attachment|
                allow(attachment).to receive(:purge_later)
            end
        end
        let(:mock_attachments2) do
            instance_double('ActiveStorage::Attachment', signed_id: 'abc123').tap do |attachment|
                allow(attachment).to receive(:purge_later)
            end
        end

        let(:attachments1) { [mock_attachments1] }
        let(:attachments2) { [mock_attachments2] }

        context 'when create article and article comment and when no attachements' do
            it '消されるべきblobデータがpurgeされること' do
                unused_blob_signed_ids = ['abc123', 'def123']
                unused_blob_delete(unused_blob_signed_ids, blob_finder: blob_finder)

                expect(mock_blob1).to have_received(:purge_later)
                expect(mock_blob2).to have_received(:purge_later)
            end
        end

        context 'when update article and article comment' do
            it '消されるべきblobデータがpurgeされること' do
                unused_blob_signed_ids = ['abc123', 'def123']
                unused_blob_delete(unused_blob_signed_ids, blob_finder: blob_finder, attachments_finder: attachments_finder)

                expect(mock_attachments1).to have_received(:purge_later)
                expect(mock_attachments2).to have_received(:purge_later)
            end
        end
    end
end
