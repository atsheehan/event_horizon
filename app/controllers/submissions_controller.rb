class SubmissionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @assignment = Assignment.find(params[:assignment_id])
    if current_user.instructor?
      @submissions = @assignment.submissions
    else
      @submissions = @assignment.submissions.where(user: current_user)
    end
  end

  def show
    if current_user.instructor?
      @submission = Submission.find_by(id: params[:id]) || not_found
    else
      @submission = current_user.submissions.
        find_by(id: params[:id]) || not_found
    end

    @comment = Comment.new
  end

  def new
    @assignment = Assignment.find(params[:assignment_id])
    @submission = Submission.new
  end

  def create
    @assignment = Assignment.find(params[:assignment_id])
    @submission = @assignment.submissions.build(submission_params)
    @submission.user = current_user

    if @submission.save
      flash[:info] = "Solution submitted."
      redirect_to submission_path(@submission)
    else
      render :new
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:body)
  end
end
