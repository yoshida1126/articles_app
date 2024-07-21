class ArticlesController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:update, :destroy]

  def show 
    @article = Article.find(params[:id]) 
  end 

  def new
    @article = Article.new
  end

  def create
    @article = current_user.articles.build(article_params) 
    @article.image.attach(params[:article][:image])

    # unless params[:blob_signed_ids].empty? 
    #   params[:blob_signed_ids].each do |blob_signed_id| 
    #     blob = ActiveStorage::Blob.find_signed(blob_signed_id) 
    #     @article.article_images.attach([blob])
    #   end 
    # end 

    if @article.save 
      flash[:notice] = "記事を作成しました。" 
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
    if @article.update(article_params)
      flash[:notice] = "記事を編集しました。" 
      redirect_to current_user, status: :see_other 
    else 
      render 'articles/edit', status: :unprocessable_entity 
    end 
  end

  def destroy
    @article.destroy
    flash[:notice] = "記事を削除しました。" 
    redirect_to current_user, status: :see_other 
  end

  private 

  def article_params 
    params.require(:article).permit(:title, :content, :image)
  end 

  def correct_user 
    @article = current_user.articles.find_by(id: params[:id]) 
    redirect_to root_url, status: :see_other if @article.nil? 
  end 
end
