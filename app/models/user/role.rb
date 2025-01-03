module User::Role
  extend ActiveSupport::Concern

  included do
    enum :role, { member: "member", administrator: "administrator" }
  end

  def can_administrate?
    administrator?
  end

  def can_manage_projects?
    @can_manage_projects ||= projects.merge(ProjectAssignment.manager).exists?
  end

  def can_manage_project?(project_id)
    @can_manage_project ||= projects.merge(ProjectAssignment.manager).exists?(id: project_id)
  end
end
