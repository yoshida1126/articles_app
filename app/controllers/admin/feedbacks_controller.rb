class Admin::FeedbacksController < Admin::BaseController
  def index
    @feedbacks = Feedback.all
  end

  def destroy
    @feedback = Feedback.find(params[:id])

    @feedbacks = Feedback.all

    respond_to do |format|
      if @feedback.destroy
        format.turbo_stream
      end
    end
  end
end
