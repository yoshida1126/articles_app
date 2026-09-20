class UsersController < ApplicationController
  before_action :unconfirmed_account_check, only: [:show, :private_articles, :drafts]
  before_action :authorize_user!, only: [:private_articles, :drafts]

  def show
    @articles = @user.articles.published.with_display_article_images.paginate(page: params[:page], per_page: 15)
    @private_articles = @user.articles.unpublished.with_display_article_images.paginate(page: params[:page], per_page: 15)

    @liked_article_ids = fetch_liked_article_ids(@articles.map(&:id))

    @tab = :published
    render :show
  end

  def private_articles
    @articles = @user.articles.published.with_display_article_images.paginate(page: params[:page], per_page: 15)
    @articles_count = @articles.count

    @liked_article_ids = fetch_liked_article_ids(@articles.map(&:id))

    @private_articles = @user.articles.unpublished.paginate(page: params[:page], per_page: 15)
    @tab = :private
    render :show
  end

  def drafts
    @articles = @user.articles.published.with_display_article_images.paginate(page: params[:page], per_page: 15)
    @articles_count = @articles.count

    @liked_article_ids = fetch_liked_article_ids(@articles.map(&:id))

    @drafts = @user.article_drafts.editing.paginate(page: params[:page], per_page: 15)

    @tab = :drafts
    render :show
  end

  def favorite_article_lists
    @user = User.find(params[:id])

    if params[:type] == "bookmark"
      @lists = FavoriteArticleList
                 .joins(:favorite_list_bookmarks)
                 .where(favorite_list_bookmarks: { user_id: @user.id })
                 .includes(
                   articles: {
                     image_attachment: :blob
                   }
                 )
                 .paginate(page: params[:page], per_page: 15)
      @list_type = :bookmark
    else
      @lists = @user.favorite_article_lists
                 .includes(
                   articles: {
                     image_attachment: :blob
                   }
                 )
                 .paginate(page: params[:page], per_page: 15)
      @list_type = :my
    end

    @articles = @user.articles.published.with_display_article_images.paginate(page: params[:page], per_page: 15)
    @articles_count = @articles.count

    @liked_article_ids = fetch_liked_article_ids(@articles.map(&:id))

    @tab = :lists
    render :show
  end

  def liked_articles
    @user = User.find(params[:id])
    @liked_articles = @user.liked_articles.with_display_images.paginate(page: params[:page], per_page: 15)

    @liked_article_ids = fetch_liked_article_ids(@liked_articles.map(&:id))

    @articles = @user.articles.published.with_display_article_images.paginate(page: params[:page], per_page: 15)
    @articles_count = @articles.count

    @tab = :liked
    render :show
  end

  def account_delete_confirmation
    @user = current_user
  end

  def following
    @title = 'フォローしているユーザー'
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page], per_page: 15)
    @articles = @user.articles
    render 'show_follow'
  end

  def followers
    @title = 'フォロワー'
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page], per_page: 15)
    @articles = @user.articles
    render 'show_follow'
  end

  private

  def unconfirmed_account_check
    @user = User.find(params[:id])
    if @user.confirmed_at.nil?
      redirect_to root_url
    else
      @user
    end
  end
end
