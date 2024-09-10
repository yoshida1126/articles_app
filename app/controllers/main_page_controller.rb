class MainPageController < ApplicationController
  def home
    to = Time.current.at_end_of_day 
    from = (to - 6.day).at_beginning_of_day 
    @weekly_trend_articles = Article.where(created_at: from...to).includes(:likes).limit(15).sort_by { |article| -article.likes.size}
    if current_user == nil || current_user.following.blank?
      @articles = Article.limit(15) 
    else 
      @articles = current_user.feed 
    end 
    @tags = ActsAsTaggableOn::Tag.most_used(5)
    if @tags.present? 
      @tags.each_with_index do |tag, i|
        instance_variable_set("@tag#{i + 1}", tag)
        instance_variable_set("@tag#{i + 1}_name", tag.name)
        instance_variable_set("@trend#{i + 1}_tag_articles", Article.tagged_with(tag).limit(15))
      end
    end 
  end

  def trend 
    to = Time.current.at_end_of_day 
    from = (to - 6.day).at_beginning_of_day 
    @weekly_trend_articles = Article.where(created_at: from...to).includes(:likes).limit(100).sort_by { |article| -article.likes.size}
    render "articles/index"
  end 

  def recentry
    if current_user == nil || current_user.following.blank?
      @articles = Article.all.paginate(page: params[:page], per_page: 30)
      render "articles/index"
    else 
      @articles = current_user.feed.paginate(page: params[:page], per_page: 30) 
      render "articles/index"
    end 
  end 

  def recommend_articles
  end 

  def trend_tag_articles
    @tag = ActsAsTaggableOn::Tag
    @tag1_name = @tag.name 
    @trend1_tag_articles = Article.tagged_with(@tag).paginate(page: params[:page], per_page: 30)
    render "articles/index" 
  end 
end
