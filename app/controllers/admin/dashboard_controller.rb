class Admin::DashboardController < Admin::BaseController

  def index
    @user_count = User.count
    @article_count = Article.count
    @comment_count = ArticleComment.count
  end
end
