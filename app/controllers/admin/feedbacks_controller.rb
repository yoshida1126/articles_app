class Admin::FeedbacksController < Admin::BaseController
  def index
    @feedbacks = Feedback.all
  end

  def destroy
  end
end
