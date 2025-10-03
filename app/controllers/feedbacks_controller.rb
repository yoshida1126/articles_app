class FeedbacksController < ApplicationController
  before_action :logged_in_user, only: %i[new create]

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = current_user.feedbacks.build(feedback_params)

    if @feedback.save
      flash[:notice] = 'フィードバックを送信しました。'
      redirect_to root_path
    else
      render 'feedbacks/new', status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:subject, :body)
  end
end
