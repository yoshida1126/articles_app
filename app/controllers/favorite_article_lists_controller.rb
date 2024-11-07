class FavoriteArticleListsController < ApplicationController
    before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
    before_action :correct_user, only: [:edit, :update, :destroy]

    def index 
        @user = User.find_by(id: params[:user_id])
        @favorite_article_lists = @user.favorite_article_lists.paginate(page: params[:page], per_page: 30) 
    end 

    def show 
        @favorite_article_list = FavoriteArticleList.find_by(id: params[:id]) 
        @favorites = @favorite_article_list.favorites.paginate(page: params[:page], per_page: 30)  
    end 

    def new 
        @user = User.find_by(id: params[:user_id])
        @favorite_article_list = FavoriteArticleList.new 
    end 

    def create 
        @favorite_article_list = current_user.favorite_article_lists.build(favorite_article_list_params)

        if @favorite_article_list.save 
          flash[:notice] = "お気に入り記事のリストを作成しました。" 
          redirect_to user_favorite_article_lists_path(current_user)
        else 
          render 'favorite_article_lists/new', status: :unprocessable_entity 
        end 
    end 

    def edit 
      @favorite_article_list = FavoriteArticleList.find(params[:id])
      @favorites = @favorite_article_list.favorites.paginate(page: params[:page], per_page: 30)  
    end 

    def update 
      @favorite_article_list = FavoriteArticleList.find(params[:id])

      if @favorite_article_list.update(favorite_article_list_params)
        flash[:notice] = "リストを編集しました。" 
        redirect_to user_favorite_article_lists_path(current_user), status: :see_other 
      else 
        render 'favorite_article_lists/edit', status: :unprocessable_entity 
      end 
    end 

    def destroy 
      @favorite_article_list = FavoriteArticleList.find(params[:id]) 
      @favorite_article_list.destroy
      flash[:notice] = "リスト #{ @favorite_article_list.list_title } を削除しました。" 
      redirect_to user_favorite_article_lists_path(current_user), status: :see_other 
    end 

    private 

    def favorite_article_list_params 
      params.require(:favorite_article_list).permit(:list_title, :articles, :article_id)
    end 

    def correct_user 
      @favorite_article_list = current_user.favorite_article_lists.find_by(id: params[:id]) 
      if @favorite_article_list.nil? 
        flash[:alert] = "#{current_user.name}さんのリスト以外は編集できません。"
        redirect_to root_url, status: :see_other
      end  
    end 
end
