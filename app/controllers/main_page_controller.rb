class MainPageController < ApplicationController
  def home
    if current_user 
      @articles = current_user.feed 
    else 
      @articles = Article.limit(15) 
    end 
  end
end
