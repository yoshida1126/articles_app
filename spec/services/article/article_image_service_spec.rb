require 'rails_helper'

RSpec.describe ArticleImageService, type: :service do
    describe '#process' do
        context 'when action is :save_draft and images are not attached' do
            let!(:user) { FactoryBot.create(:user) }
            let(:params) do
                ActionController::Parameters.new(
                    article_draft: {
                        title: "test",
                        content: "test",
                        tag_list: "test"
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :save_draft) }

            it 'ArticleDraftモデルのインスタンスが返ってくること' do 
                result = service.process
                expect(result).to be_a(ArticleDraft)
            end
        end

        context 'when action is :save_draft and images are attached' do
            let!(:user) { FactoryBot.create(:user) }
            let(:params) do
                ActionController::Parameters.new(
                    article_draft: {
                        title: "test",
                        content: "test content",
                        tag_list: "tag",
                        blob_signed_ids: ['abc123'].to_json
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :save_draft) }

            it 'handle_article_images_for_save_draft_and_commitを呼び出す' do
                expect(service).to receive(:handle_article_images_for_save_draft_and_commit).and_call_original
                service.process
            end

            it 'ArticleDraftモデルのインスタンスが返ってくること' do
                result = service.process
                expect(result).to be_an(ArticleDraft)
            end
        end

        context 'when action is :commit and images are not attached' do
            let!(:user) { FactoryBot.create(:user) }
            let(:params) do
                ActionController::Parameters.new(
                    article: { published: "true" },
                    article_draft: {
                        title: "test",
                        content: "test",
                        tag_list: "test",
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :commit) }

            it 'ArticleモデルのインスタンスとArticleDraftモデルのインスタンスが返ってくること' do 
                result_article, result_draft = service.process

                expect(result_article).to be_a(Article)
                expect(result_draft).to be_a(ArticleDraft)
            end
        end

        context 'when action is :commit and images are attached' do
            let!(:user) { FactoryBot.create(:user) }
            let(:params) do
                ActionController::Parameters.new(
                    article: { published: "true" },
                    article_draft: {
                        title: "test",
                        content: "test",
                        tag_list: "test",
                        blob_signed_ids: ['abc123'].to_json
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :commit) }

            it 'handle_article_images_for_save_draft_and_commitを呼び出す' do
                expect(service).to receive(:handle_article_images_for_save_draft_and_commit).and_call_original
                service.process
            end

            it 'ArticleモデルのインスタンスとArticleDraftモデルのインスタンスが返ってくること' do
                result_article, result_draft = service.process

                expect(result_article).to be_a(Article)
                expect(result_draft).to be_a(ArticleDraft)
            end
        end

        context 'when action is :update_draft and images are not attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article_draft) { FactoryBot.create(:article_draft, user: user) }
            let(:params) do
                ActionController::Parameters.new(
                    id: article_draft.id,
                    article_draft: {
                        title: "test",
                        content: "test",
                        tag_list: "test"
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :update_draft) }

            it 'ArticleDraftモデルのインスタンスとパラメータが返ってくること' do 
                result_draft, result_params = service.process
                expect(result_draft).to be_a(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :update_draft and images are attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article_draft) { FactoryBot.create(:article_draft, user: user) }
            let(:params) do
                ActionController::Parameters.new(
                    id: article_draft.id,
                    article_draft: {
                        title: "test",
                        content: "test content",
                        tag_list: "tag",
                        blob_signed_ids: ['abc123'].to_json
                    }
                )
            end
            let!(:service) { ArticleImageService.new(user, params, :update_draft) }

            it 'handle_article_images_for_createを呼び出す' do
                expect(service).to receive(:handle_article_images_for_update_draft).and_call_original
                service.process
            end

            it 'ArticleDraftモデルのインスタンスとパラメータが返ってくること' do
                result_draft, result_params = service.process
                expect(result_draft).to be_a(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :update and images are not attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article_draft) { FactoryBot.create(:article_draft, user: user) }
            let(:params) do
                ActionController::Parameters.new(
                    id: article_draft.id,
                    article_draft: {
                        title: "test",
                        content: "test",
                        tag_list: "test"
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :update) }

            it 'ArticleDraftモデルのインスタンスとパラメータが返ってくること' do 
                result_draft, result_params = service.process
                expect(result_draft).to be_a(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :update and images are attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article_draft) { FactoryBot.create(:article_draft, user: user) }
            let(:params) do
                ActionController::Parameters.new(
                    id: article_draft.id,
                    article_draft: {
                        title: "test",
                        content: "test content",
                        tag_list: "tag",
                        blob_signed_ids: ['abc123'].to_json
                    }
                )
            end
            let!(:service) { ArticleImageService.new(user, params, :update) }

            it 'handle_article_images_for_createを呼び出す' do
                expect(service).to receive(:handle_article_images_for_update_draft).and_call_original
                service.process
            end

            it 'ArticleDraftモデルのインスタンスとパラメータが返ってくること' do
                result_draft, result_params = service.process
                expect(result_draft).to be_a(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is unexpected action name' do
            let!(:user) { FactoryBot.create(:user) }
            let(:params) do
                ActionController::Parameters.new(
                    article_draft: {
                        title: "test",
                        content: "test",
                        tag_list: "test"
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :unexpected_action) }

            it 'エラーが起きること' do
                expect {
                    service.process
                }.to raise_error(RuntimeError)
            end
        end
    end
end