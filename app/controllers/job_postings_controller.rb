class JobPostingsController < ApplicationController
  before_action :check_for_redirect, only: [:show]
  before_action :checkAccountCompleteUser, only: [:joblist]
  before_action :checkAccountCompleteCompany, only: [:new, :index]

  def create
    @jobpostings = current_company.job_postings.build(job_posting_params)
    if @jobpostings.save
      flash[:success] = "Created new job posting"
      redirect_to activity_companies_path(current_company)
    else
      render 'new'
    end
  end

  def destroy
    if current_company
      current_company.job_postings.find_by(id: params[:id]).destroy
      flash[:success] = "Job Posting Removed"
      redirect_to activity_companies_path
    else
      flash[:danger] = "You do not have permission to complete this operation"
      redirect_to root_url
    end
  end

  def new
    if current_company.status != 2
      flash[:danger] ="Your account is still awaiting approval. This process can take up to 24 hours. We appreciate your patience."
      redirect_to current_company
    else
      @jobpostings = JobPosting.new
    end
  end

  def index
    @company = current_company
    @jobpostings = @company.job_postings.paginate(page: params[:page], per_page: 3)
  end

  def joblist
    #@job_postings = JobPosting.paginate(page: params[:page], per_page: 10)

    if current_user.status == 0
      flash[:danger] = "Your profile is awaiting approval. This process can take up to 48 hours to complete."
      redirect_to current_user
    elsif current_user.status == 1
      flash[:danger] = "Your profile is awaiting approval. This process can take a few days to complete. We appreciate your patiencel."
      redirect_to current_user
    else
      @filterrific = initialize_filterrific(
          JobPosting,
          params[:filterrific],
          select_options: {
              sorted_by: JobPosting.options_for_sorted_by,
              with_location: getCities,
              with_sector: getType
          }#,
          #persistence_id: 'shared_key',
          #default_filter_params: {},
          #available_filters: [],
      ) or return

      @job_postings = @filterrific.find.page(params[:page])


      respond_to do |format|
        format.html
        format.js
    end

  end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return

  end

  def show
    if !current_company.nil? && current_company.admin == false
      @jobposting = current_company.job_postings.find_by(id: params[:id])
    else
      @jobposting = JobPosting.find_by(id: params[:id])
      if current_user
        @jobposting.update_attribute(:views, increment_view_count(@jobposting))
      end
    end
  end

  def edit
    @job = JobPosting.find(params[:id])
  end

  def update
    @job = JobPosting.find(params[:id])
    if @job.update_attributes(job_posting_params)
      flash.now[:success] = "Posting Updated"
      redirect_to activity_companies_path
    else
      render 'edit'
    end
  end

  private

    def job_posting_params
      params.require(:job_posting).permit(:title, :location, :province, :description, :type, :sector, :hours, :length)
    end

    def check_for_redirect
      unless user_logged_in? || company_logged_in?
        store_location
        flash[:danger] = "Please Log In"
        redirect_to login_url
      end
    end


    def checkAccountCompleteUser
      unless UserProfileIsComplete?
        flash[:danger] = "Please complete your profile before proceeding"
        redirect_to edit_user_path(current_user)
      end
    end

    def checkAccountCompleteCompany
      unless CompanyProfileIsComplete?
        flash[:danger] = "Please complete your profile before proceeding"
        redirect_to edit_company_path(current_company)
      end
    end

end
