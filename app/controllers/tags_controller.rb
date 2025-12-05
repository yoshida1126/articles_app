class TagsController < ApplicationController
  def show
    if turbo_frame_request? && params[:page].present?
      @search_articles = Article.published.tagged_with(params[:id]).paginate(page: params[:page], per_page: 30)
      render partial: "searches/search_articles_page",
             locals: { search_articles: search_articles }
      return
    end

    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:id])

    @tagged_articles = Article.published.tagged_with(params[:id])

    @total_articles_count = @tagged_articles.count

    @tagged_articles = @tagged_articles.paginate(page: params[:page], per_page: 30)
  end
end
