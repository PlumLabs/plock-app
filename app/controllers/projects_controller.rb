class ProjectsController < ApplicationController
  before_action :ensure_can_administrate, only: %i[ new create destroy ]
  before_action :ensure_can_manage_projects, unless: -> { Current.user.can_administrate? }, only: %i[ index ]
  before_action -> { ensure_can_manage_project(params[:id]) unless Current.user.can_administrate? }, only: %i[ show edit update ]
  before_action :set_project, only: %i[ show edit update destroy ]

  def index
    @projects = filter_projects(project_scope).then { search_projects(_1) }
  end

  def show
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: "Project was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: "updated" }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project.disable!

    respond_to do |format|
      format.html { redirect_to projects_path, status: :see_other, notice: "archived" }
    end
  end

  private
    def set_project
      @project = Project.includes(project_assignments: :user).find(params.expect(:id))
    end

    def project_params
      params.expect(project: [ :name, :client_id, :disabled_at ])
    end

    def query_params
      return {} if params[:q].nil?

      params.expect(q: [ :name_or_clients_name_cont, :status_eq, :client_id ])
    end

    def project_scope
      if Current.user.can_administrate?
        Project.includes(:client).all
      else
        Current.user.projects.merge(ProjectAssignment.manager).includes(:client)
      end
    end

    def filter_projects(scope)
      filter_by_status(scope).then { filter_by_client(_1) }
    end

    def filter_by_status(scope)
      return scope if query_params.dig(:status_eq).blank?

      case query_params.dig(:status_eq)
      when "active"
        scope.active
      when "archive"
        scope.archive
      else
        scope
      end
    end

    def filter_by_client(scope)
      return scope if query_params.dig(:client_id).blank?

      scope.where(client_id: query_params.dig(:client_id))
    end

    def search_projects(scope)
      return scope if query_params.dig(:name_or_clients_name_cont).blank?

      scope.left_joins(:client).where("projects.name LIKE :q or clients.name LIKE :q", q: "%#{query_params.dig(:name_or_clients_name_cont)}%")
    end
end
