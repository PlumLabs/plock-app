class Report::DetailedFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :start_date, :date, default: -> { Date.current.beginning_of_month }
  attribute :end_date, :date, default: -> { Date.current.end_of_month }
  attribute :user_ids, array: true, default: []
  attribute :project_ids, array: true, default: []
  attribute :client_ids, array: true, default: []

  alias_attribute :mobile_user_ids, :user_ids
  alias_attribute :mobile_project_ids, :project_ids
  alias_attribute :mobile_client_ids, :client_ids

  def initialize(attributes = {})
    @current_user = attributes.delete(:current_user)
    super(attributes)
  end

  def clients
    scope = Client.order(name: :asc)
    return scope if current_user.can_administrate?

    scope.where(id: projects_where_user_is_manager.select(:client_id))
  end

  def projects
    return Project.order(name: :asc) if current_user.can_administrate?

    projects_where_user_is_manager.order(name: :asc)
  end

  def users
    scope = User.order(first_name: :asc, last_name: :asc)
    return scope if current_user.can_administrate?

    scope.joins(:projects).where(projects: { id: projects_where_user_is_manager.select(:id) }).distinct
  end

  def results
    order_entries.includes(:project, :user).then { filter_entries(_1) }
  end

  def total_minutes
    results.sum(:duration_minutes)
  end

  private

  attr_reader :current_user

  def projects_where_user_is_manager
    current_user.projects.merge(ProjectAssignment.manager)
  end

  def order_entries(scope = TimeEntry.limit(400))
    scope.order(date: :desc).order(user_id: :asc)
  end

  def filter_entries(scope)
    filter_by_date(scope)
      .then { filter_by_clients(_1) }
      .then { filter_by_projects(_1) }
      .then { filter_by_users(_1) }
      .then { filter_by_role(_1) }
  end

  def filter_by_clients(scope)
    client_ids.compact_blank!
    return scope unless client_ids.any?

    scope.joins(:project).where(project: { client_id: client_ids })
  end

  def filter_by_projects(scope)
    project_ids.compact_blank!
    return scope unless project_ids.any?

    scope.where(project_id: project_ids)
  end

  def filter_by_users(scope)
    user_ids.compact_blank!
    return scope unless user_ids.any?

    scope.where(user_id: user_ids)
  end

  def filter_by_date(scope)
    return scope if start_date.blank? || end_date.blank?

    scope.where(date: start_date..end_date)
  end

  def filter_by_role(scope)
    return scope if current_user.can_administrate?

    # previous filter joins projects, so we can use it here
    scope.where(projects: { id: projects_where_user_is_manager.select(:id) })
  end
end
