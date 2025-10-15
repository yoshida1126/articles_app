class ArticleDraftsController < ApplicationController
  before_action :logged_in_user, only: %i[new create edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]

  private

  def correct_user
    # 記事の作成者が、現在ログイン中のユーザーかを確認
    @draft = ArticleDraft.find(params[:id])
    
    authorize_resource_owner(@article)
  end
end
