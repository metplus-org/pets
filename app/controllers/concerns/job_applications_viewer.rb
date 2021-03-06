module JobApplicationsViewer
  extend ActiveSupport::Concern

  def display_job_applications(application_type, id)
    case application_type
    when 'job_seeker-default'
      collection = JobApplication.active_companies.where(job_seeker: id)
    when 'job_seeker-company-person'
      collection = JobApplication.where(job_seeker: id).joins(:job)
                                 .where('jobs.company_id = ?', pets_user.company_id)
    when 'job-job-developer'
      collection = JobApplication.where(job: id, job_seeker_id: AgencyRelation
                                 .where(agency_person: pets_user, agency_role_id: 1)
                                 .select(:job_seeker_id))
                                 .includes(:job_seeker)
    when 'job-company-person'
      collection = JobApplication.where(job: id)
                                 .includes(:job_seeker)
    end
    collection.order(default_sorting(application_type))
  end

  FIELDS_IN_APPLICATION_TYPE = {
    'job_seeker-default': [:title, :description, :company, :applied_at, :status],
    'job_seeker-company-person': [:title, :applied_at, :status, :action],
    'job-job-developer': [:name, :js_status, :applied_at, :status],
    'job-company-person': [:name, :js_status, :applied_at, :status, :action]
  }.freeze

  def application_fields(application_type)
    FIELDS_IN_APPLICATION_TYPE[application_type.to_sym] || []
  end

  DEFAULT_SORTING = {
    'job_seeker-default': { id: :asc },
    'job_seeker-company-person': { id: :asc },
    'job-job-developer': { id: :asc, status: :asc },
    'job-company-person': { status: :asc, updated_at: :desc }
  }.freeze

  def default_sorting(application_type)
    DEFAULT_SORTING[application_type.to_sym] || {}
  end

  # make helper methods visible to views
  def self.included(m)
    return unless m < ActionController::Base

    m.helper_method :application_fields
  end
end
