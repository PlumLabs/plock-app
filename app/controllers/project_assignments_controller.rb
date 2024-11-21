class ProjectAssignmentsController < ApplicationController
  before_action :ensure_can_administrate
  before_action :set_project, only: %i[ new create destroy edit update ]
  before_action :set_project_assignment, only: %i[ destroy edit update ]

  def new
    scope = User.all.excluding(@project.users).order(:first_name, :last_name)
    @users = search_users(scope)
  end

  def create
    @project_assignment = @project.project_assignments.new(project_assignment_params)

    respond_to do |format|
      if @project_assignment.save
        format.html { redirect_to @project, notice: "created" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @project_assignment.update(project_assignment_params)
        format.html { redirect_to @project, notice: "updated" }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project_assignment.destroy!

    respond_to do |format|
      format.html { redirect_to @project, status: :see_other, notice: "destroyed" }
    end
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_project_assignment
      @project_assignment = @project.project_assignments.find(params.expect(:id))
    end

    def project_assignment_params
      params.expect(project_assignment: [ :user_id, :role ])
    end

    def query_params
      return {} if params[:q].nil?

      params.expect(q: [ :first_name_or_last_name_or_email_cont ])
    end

    def search_users(scope)
      return scope if query_params.dig(:first_name_or_last_name_or_email_cont).blank?

      scope.where("first_name LIKE :q OR last_name LIKE :q OR email_address LIKE :q",
                  q: "%#{query_params.dig(:first_name_or_last_name_or_email_cont)}%")
    end
end
