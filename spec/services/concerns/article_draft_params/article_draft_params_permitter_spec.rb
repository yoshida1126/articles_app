require 'rails_helper'

RSpec.describe ArticleDraftParams::ArticleDraftParamsPermitter do
    let!(:permitter_class) do
        Class.new { include ArticleDraftParams::ArticleDraftParamsPermitter }
    end
    let!(:user) { FactoryBot.create(:user) }
    let(:article_draft) { FactoryBot.create(:article_draft, user: user) }
    let!(:params) do
        ActionController::Parameters.new(
            article_draft: {
                title: "test",
                content: "test",
                tag_list: "test"
            }
        )
    end

    describe '#sanitized_article_draft_params' do
        it '変更を許可されたパラメータが返ってくること' do
            sanitized_params = permitter_class.new.sanitized_article_draft_params(params)
            permitted_params = params.require(:article_draft).permit(:title, :content, :image, :tag_list, article_images: [])

            expect(sanitized_params).to eq (permitted_params)
        end
    end
end