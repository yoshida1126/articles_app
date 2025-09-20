require 'rails_helper'

RSpec.describe ArticleCommentParams::ArticleCommentParamsPermitter do
    let!(:permitter_class) do
        Class.new { include ArticleCommentParams::ArticleCommentParamsPermitter }
    end
    let!(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.create(:article, user: user) }
    let!(:params) do
        ActionController::Parameters.new(
            article_id: article.id,
            article_comment: {
                comment: "test comment",
                blob_signed_ids: "[]"
            }
        )
    end

    describe '#sanitized_article_params' do
        it '変更を許可されたパラメータが返ってくること' do
            sanitized_params = permitter_class.new.sanitized_article_comment_params(params)
            permitted_params = params.require(:article_comment).permit(:comment, :created_at, :updated_at, comment_images: [])

            expect(sanitized_params).to eq (permitted_params)
        end
    end
end