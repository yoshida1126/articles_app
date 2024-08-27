class MainPageController < ApplicationController
  def home
    to = Time.current.at_end_of_day 
    from = (to - 6.day).at_beginning_of_day 
    @weekly_trend_articles = Article.includes(:likes).limit(10).sort_by { |article| -article.likes.where(created_at: from..to).count }
 
    if current_user == nil || current_user.following.blank?
      @articles = Article.limit(15) 
    else 
      @articles = current_user.feed 
    end 
  end
end
