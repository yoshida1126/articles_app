class ArticlesController < ApplicationController
  before_action :logged_in_user, only: %i[new create edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]

  def index; end

  def show
    @article = Article.find(params[:id])
    @tags = @article.tag_counts_on(:tags)
    @article_comment = ArticleComment.new
    return unless current_user

    @favorite_article_lists = current_user.favorite_article_lists
    @favorite = Favorite.new
  end

  def new
    @article = Article.new
  end

  def create
    @article = current_user.articles.build(image_resize(article_params))
    @article.image.attach(article_params[:image])

    # unless params[:blob_signed_ids].empty?
    #   params[:blob_signed_ids].each do |blob_signed_id|
    #     blob = ActiveStorage::Blob.find_signed(blob_signed_id)
    #     @article.article_images.attach([blob])
    #   end
    # end

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
    if article_params[:image]
      @article.image.purge
      params = image_resize(article_params)
      @article.image.attach(params[:image])
      if @article.update(params)
        flash[:notice] = '記事を編集しました。'
        redirect_to current_user, status: :see_other
      else
        render 'articles/edit', status: :unprocessable_entity
      end
    elsif @article.update(article_params)
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

  def article_params
    params.require(:article).permit(:title, :content, :image, :tag_list)
  end

  def correct_user
    @article = current_user.articles.find_by(id: params[:id])
    return unless @article.nil?

    flash[:alert] = "#{current_user.name}さんの記事以外は編集できません。"
    redirect_to root_url, status: :see_other
  end

  def image_resize(params)
    if params[:image]
      params[:image].tempfile = ImageProcessing::MiniMagick.source(params[:image].tempfile).resize_to_limit(1024,
                                                                                                            1024).call
    end
    params
  end
end
