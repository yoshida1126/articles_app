class ArticlesController < ApplicationController
  before_action :logged_in_user, only: %i[new create edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]

  def index; end

  def show
    # 記事のページの情報を取得する
    @article = Article.find(params[:id])
    @tags = @article.tag_counts_on(:tags)
    @comment = ArticleComment.new
    return unless current_user

    # 以下はログイン時のみ必要な情報
    @favorite_article_lists = current_user.favorite_article_lists
    @favorite = Favorite.new
  end

  def new
    @article = Article.new
  end

  def create
    @article = ArticleImageService.new(current_user, params, :create).process

    if @article.save
      flash[:notice] = '記事を作成しました。'
      redirect_to current_user
    else
      render 'articles/new', status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user
    @article = @user.articles.find(params[:id])
  end

  def update
    service = ArticleImageService.new(current_user, params, :update)
    @article, @params = service.process

    if @article.update(service.sanitized_article_params(@params))
      flash[:notice] = '記事を編集しました。'
      redirect_to current_user, status: :see_other
    else
      render 'articles/edit', status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    flash[:notice] = '記事を削除しました。'
    redirect_to current_user, status: :see_other
  end

  private

  def correct_user
    # 記事の作成者が、現在ログイン中のユーザーであるかを確認
    @article = current_user.articles.find_by(id: params[:id])
    return unless @article.nil?

    flash[:alert] = "#{current_user.name}さんの記事以外は編集できません。"
    redirect_to root_url, status: :see_other
  end
end
