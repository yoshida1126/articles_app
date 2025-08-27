class TagsController < ApplicationController
  def show
    # 関連するタグがつけられた記事の一覧を取得
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:id])

    redirect_to root_path, alert: '存在しないタグです。' unless @tag.present?

    @tagged_articles = Article.tagged_with(params[:id])

    @total_articles_count = @tagged_articles.count

    @tagged_articles = @tagged_articles.paginate(page: params[:page], per_page: 30)
  end
end
