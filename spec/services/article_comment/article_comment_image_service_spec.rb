require 'rails_helper'

RSpec.describe ArticleImageService, type: :service do
    describe '#process' do
        context 'when action is :create and images are not attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article) { FactoryBot.create(:article) }
            let!(:params) do
                ActionController::Parameters.new(
                    article_id: article.id,
                    article_comment: {
                        comment: "test comment",
                        blob_signed_ids: "[]"
                    }
                )
            end
            let(:service) { ArticleCommentImageService.new(user, params, :create) }

            it 'ArticleCommentモデルのインスタンスが返ってくること' do 
                result = service.process
                expect(result).to be_a(ArticleComment)
            end
        end

        context 'when action is :create and images are attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article) { FactoryBot.create(:article) }
            let!(:params) do
                ActionController::Parameters.new(
                    article_id: article.id,
                    article_comment: {
                        comment: "test comment",
                        blob_signed_ids: ['abc123'].to_json
                    }
                )
            end
            let!(:service) { ArticleCommentImageService.new(user, params, :create) }

            it 'handle_article_comment_images_for_createを呼び出す' do
                expect(service).to receive(:handle_article_comment_images_for_create).and_call_original
                service.process
            end

            it 'ArticleCommentモデルのインスタンスが返ってくること' do
                result = service.process
                expect(result).to be_an(ArticleComment)
            end
        end

        context 'when action is :update and images are not attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article_comment) { FactoryBot.create(:article_comment, user: user, article: article) }
            let!(:article) { FactoryBot.create(:article) }
            let!(:params) do
                ActionController::Parameters.new(
                    id: article_comment.id,
                    aritlce_id: article.id,
                    article_comment: {
                        comment: "test comment",
                        blob_signed_ids: "[]"
                    }
                )
            end
            let(:service) { ArticleCommentImageService.new(user, params, :update) }

            it 'ArticleCommentモデルのインスタンスとパラメータが返ってくること' do 
                result_article_comment, result_params = service.process

                expect(result_article_comment).to be_a(ArticleComment)
                expect(result_params).to eq(params)
            end
        end

        context 'when action is :update and images are attached' do
            let!(:user) { FactoryBot.create(:user) }
            let!(:article_comment) { FactoryBot.create(:article_comment, user: user, article: article) }
            let!(:article) { FactoryBot.create(:article) }
            let!(:params) do
                ActionController::Parameters.new(
                    id: article_comment.id,
                    article_id: article.id,
                    article_comment: {
                        comment: "test comment",
                        blob_signed_ids: ['abc123'].to_json
                    }
                )
            end
            let(:service) { ArticleCommentImageService.new(user, params, :update) }

            it 'handle_article_comment_images_for_updateを呼び出す' do
                expect(service).to receive(:handle_article_comment_images_for_update).and_call_original
                service.process
            end

            it 'ArticleCommentモデルのインスタンスとパラメータが返ってくること' do
                result_article, result_params = service.process

                expect(result_article).to be_an(ArticleComment)
                expect(result_params).to eq(params)
            end
        end
    end
end