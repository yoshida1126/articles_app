require 'rails_helper'

RSpec.describe ArticleParams::ArticleParamsPermitter do
    let!(:permitter_class) do
        Class.new { include ArticleParams::ArticleParamsPermitter }
    end
    let!(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.create(:article, user: user) }
    let!(:params) do
        ActionController::Parameters.new(
            id: article.id,
            article: {
                title: "test",
                content: "test",
                tag_list: "test"
            }
        )
    end

    describe '#sanitized_article_params' do
        it '変更を許可されたパラメータが返ってくること' do
            sanitized_params = permitter_class.new.sanitized_article_params(params)
            permitted_params = params.require(:article).permit(:title, :content, :image, :tag_list, article_images: [])

            expect(sanitized_params).to eq (permitted_params)
        end
    end
end