class MainPageController < ApplicationController
  before_action :prepare_period_data, :fetch_trend_articles, only: [:home, :trend]

  def home
    @liked_article_ids = fetch_liked_article_ids(@trend_articles.map(&:id))

    @articles = current_user&.following.present? ? current_user.feed : Article.published.limit(15)
    # 最も使用されているタグを上位5件取得（重複除外）           
    @tags = ActsAsTaggableOn::Tag.joins(:taggings).distinct.most_used(5)
    # トレンドタグごとの記事一覧を取得（記事数が一定以上のタグのみを対象）
    @trend_tag_sections = TrendTagService.new(@tags).call
  end

  def trend
    render 'articles/index'
  end

  def recently
    @articles = if current_user.nil? || current_user.following.blank?
                  Article.all.paginate(page: params[:page], per_page: 30)
                else
                  current_user.feed.paginate(page: params[:page], per_page: 30)
                end
    render 'articles/index'
  end

  private

  def prepare_period_data
    @to = Time.current.at_end_of_day
    @from = (@to - 30.days).at_beginning_of_day
  end

  def fetch_trend_articles
    @trend_articles = Article
    .with_attached_image
    .includes(
      user: {
        profile_img_attachment: :blob
      }
    )
    .where(created_at: @from...@to)
    .where("likes_count > 0")
    .order(likes_count: :desc, created_at: :desc)
    .limit(15)

    @trend_articles.load
  end
end
