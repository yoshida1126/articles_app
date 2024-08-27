class TagsController < ApplicationController 

  def show 
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:id]) 

    @tagged_articles = Article.tagged_with(params[:id])

    @total_articles_count = @tagged_articles.count 

    @tagged_articles = @tagged_articles.paginate(page: params[:page], per_page: 32)
  end 
end 