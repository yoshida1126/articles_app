require 'rails_helper'

RSpec.describe ArticleImageService, type: :service do
    describe '#process' do
        context 'when action is :create and images are not attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:params) do
                ActionController::Parameters.new(
                    article: {
                        title: "test",
                        content: "test",
                        tag_list: "test",
                        images: [""],
                        blob_signed_ids: "[]"
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :create) }

            it 'Articleモデルのインスタンスが返ってくること' do 
                result = service.process
                expect(result).to be_a(Article)
            end
        end

        context 'when action is :create and images are attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:params) do
                ActionController::Parameters.new(
                    article: {
                        title: "test",
                        content: "test content",
                        tag_list: "tag",
                        blob_signed_ids: ['abc123'].to_json
                    }
                )
            end
            let!(:service) { ArticleImageService.new(user, params, :create) }

            it 'handle_article_images_for_createを呼び出す' do
                expect(service).to receive(:handle_article_images_for_create).and_call_original
                service.process
            end

            it 'Articleモデルのインスタンスが返ってくること' do
                result = service.process
                expect(result).to be_an(Article)
            end
        end

        context 'when action is :update and images are not attached' do
            let!(:user) { FactoryBot.create(:user) }
            let(:article) { FactoryBot.create(:article, user: user) }
            let!(:params) do
                ActionController::Parameters.new(
                    id: article.id,
                    article: {
                        title: "test",
                        content: "test",
                        tag_list: "test",
                        images: [""],
                        blob_signed_ids: "[]"
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :update) }

            it 'articleモデルのインスタンスとパラメータが返ってくること' do 
                result_article, result_params = service.process

                expect(result_article).to be_a(Article)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :update and images are attached' do
            let!(:user) { FactoryBot.create(:user) }
            let(:article) { FactoryBot.create(:article, user: user) }
            let!(:params) do
                ActionController::Parameters.new(
                    id: article.id,
                    article: {
                        title: "test",
                        content: "test",
                        tag_list: "test",
                        images: [""],
                        blob_signed_ids: ['abc123'].to_json
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :update) }

            it 'handle_article_images_for_updateを呼び出す' do
                expect(service).to receive(:handle_article_images_for_update).and_call_original
                service.process
            end

            it 'Articleモデルのインスタンスとパラメータが返ってくること' do
                result_article, result_params = service.process

                expect(result_article).to be_an(Article)
                expect(result_params).to eq(params)
            end
        end
    end
end