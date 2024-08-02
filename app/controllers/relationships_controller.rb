class RelationshipsController < ApplicationController
    before_action :logged_in_user 

    def create 
        user = User.find(params[:followed_id]) 
        current_user.follow(user) 
        flash[:notice] = "#{user.name}さんをフォローしました。" 
        redirect_to request.referer || root_path 
    end 

    def destroy 
        user = Relationship.find(params[:id]).followed 
        current_user.unfollow(user) 
        flash[:notice] = "#{user.name}さんのフォローを解除しました。"
        redirect_to request.referer || root_path, status: :see_other  
    end 
end
