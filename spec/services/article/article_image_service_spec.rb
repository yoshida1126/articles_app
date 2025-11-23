require 'rails_helper'

RSpec.describe ArticleImageService, type: :service do
    describe '#process' do
        context 'when action is :autosave_draft and draft_id is present' do
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

            let(:service) { ArticleImageService.new(user, params, :autosave_draft) }

            it 'handle_images_for_autosave_draftを呼び出す' do
                expect(service).to receive(:handle_images_for_autosave_draft).and_call_original
                service.process
            end

            it 'ArticleDraftモデルのインスタンスが返ってくること' do 
                result_draft, remaining_mb, max_size = service.process

                expect(result_draft).to be_an(ArticleDraft)
            end
        end

        context 'when action is :save_draft and draft_id is present' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article_draft) { FactoryBot.create(:article_draft, article: nil, user: user) }
            let(:params) do
                ActionController::Parameters.new(
                    article_draft: {
                        title: "test",
                        content: "test",
                        tag_list: "test",
                        draft_id: article_draft.id
                    }
                )
            end
            let(:service) { ArticleImageService.new(user, params, :save_draft) }

            it 'handle_imagesを呼び出す' do
                expect(service).to receive(:handle_images).and_call_original
                service.process
            end

            it 'ArticleDraftモデルのインスタンスとパラメータが返ってくること' do 
                result_draft, result_params = service.process

                expect(result_draft).to be_an(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :save_draft and draft_id is not present' do
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

            it 'handle_imagesを呼び出す' do
                expect(service).to receive(:handle_images).and_call_original
                service.process
            end

            it 'ArticleDraftモデルのインスタンスとパラメータが返ってくること' do
                result, result_params = service.process

                expect(result).to be_an(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :commit' do
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

            it 'handle_imagesを呼び出す' do
                expect(service).to receive(:handle_images).and_call_original
                service.process
            end

            it 'Articleモデル、ArticleDraftモデルのインスタンスとパラメータが返ってくること' do 
                result_article, result_draft, result_params = service.process

                expect(result_article).to be_an(Article)
                expect(result_draft).to be_an(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :update_draft' do
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

            it 'handle_imagesを呼び出す' do
                expect(service).to receive(:handle_images).and_call_original
                service.process
            end

            it 'ArticleDraftモデルのインスタンスとパラメータが返ってくること' do 
                result_draft, result_params, remaining_mb, max_size = service.process
                expect(result_draft).to be_an(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :update and article is not present' do
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

            it 'handle_imagesを呼び出す' do
                expect(service).to receive(:handle_images).and_call_original
                service.process
            end

            it 'Articleモデル、ArticleDraftモデルのインスタンスとパラメータが返ってくること' do 
                result_article, result_draft, result_params = service.process

                expect(result_article).to be_an(Article)
                expect(result_draft).to be_an(ArticleDraft)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :update and article is present' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user: user) }
            let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }
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

            it 'handle_imagesを呼び出す' do
                expect(service).to receive(:handle_images).and_call_original
                service.process
            end

            it 'Articleモデル、ArticleDraftモデルのインスタンスとパラメータが返ってくること' do
                result_article, result_draft, result_params = service.process

                expect(result_article).to be_an(Article)
                expect(result_draft).to be_an(ArticleDraft)
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