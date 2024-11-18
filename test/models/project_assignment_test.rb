require "test_helper"

class ProjectAssignmentTest < ActiveSupport::TestCase
  test "validates presence of project" do
    assert_not project_assignments(:one_manager).update(project: nil)
  end

  test "validates presence of user" do
    assert_not project_assignments(:one_manager).update(user: nil)
  end

  test "validates uniqueness of user scoped to project" do
    project_assignment = project_assignments(:one_manager)
    project = project_assignment.project

    assert_raises(ActiveRecord::RecordInvalid) { project.users << users(:edu) }
  end

  test "default the role to member" do
    project_assignment = ProjectAssignment.create(project: projects(:two), user: users(:edu))
    assert_equal "member", project_assignment.role
  end
end
