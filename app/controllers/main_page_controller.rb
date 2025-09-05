class MainPageController < ApplicationController
  def home
    to = Time.current.at_end_of_day
    from = (to - 30.days).at_beginning_of_day

    @trend_articles = Article
    .joins(:likes)
    .where(created_at: from...to)
    .group('articles.id')
    .select('articles.*, COUNT(likes.id) AS likes_count')
    .reorder(Arel.sql('COUNT(likes.id) DESC, articles.created_at DESC'))
    .limit(15)

    @articles = if current_user.nil? || current_user.following.blank?
                  Article.limit(15)
                else
                  current_user.feed
                end
                
    @tags = ActsAsTaggableOn::Tag.joins(:taggings).distinct.most_used(5)

    @tags.each_with_index do |tag, i|
      instance_variable_set("@tag#{i + 1}", tag)
      instance_variable_set("@tag#{i + 1}_name", tag.name)
      instance_variable_set("@trend#{i + 1}_tag_articles", Article.tagged_with(tag).limit(15))
    end
  end

  def trend
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @weekly_trend_articles = Article.where(created_at: from...to).includes(:likes).limit(100).sort_by do |article|
      -article.likes.size
    end
    render 'articles/index'
  end

  def recentry
    @articles = if current_user.nil? || current_user.following.blank?
                  Article.all.paginate(page: params[:page], per_page: 30)
                else
                  current_user.feed.paginate(page: params[:page], per_page: 30)
                end
    render 'articles/index'
  end

  def recommend_articles; end

  def trend_tag_articles
    @tag = ActsAsTaggableOn::Tag
    @tag1_name = @tag.name
    @trend1_tag_articles = Article.tagged_with(@tag).paginate(page: params[:page], per_page: 30)
    render 'articles/index'
  end
end
