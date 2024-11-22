require "test_helper"

class ProjectAssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_assignment = project_assignments(:one_manager)
    @project = @project_assignment.project
    sign_in users(:edu)
  end

  test "administrator should get new" do
    get new_project_project_assignment_url(@project)
    assert_response :success
  end

  test "administrator should create a project assignment" do
    assert_difference("ProjectAssignment.count") do
      post project_project_assignments_path(@project), params: { project_assignment: { user_id: users(:franco).id } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "administrator should get edit" do
    get edit_project_project_assignment_url(@project, @project_assignment)
    assert_response :success
  end

  test "administrator should update a project assignment" do
    patch project_project_assignment_path(@project, @project_assignment),
          params: { project_assignment: { role: "manager" } }

    assert_redirected_to project_url(@project)
  end

  test "administrator should destroy project assigment" do
    assert_difference("ProjectAssignment.count", -1) do
      delete project_project_assignment_url(@project, @project_assignment)
    end

    assert_redirected_to project_url(@project)
  end

  test "memeber should not get new" do
    users(:edu).update!(role: "member")

    get new_project_project_assignment_url(@project)
    assert_response :forbidden
  end

  test "memeber should not create project" do
    users(:edu).update!(role: "member")

    post project_project_assignments_path(@project), params: { project_assignment: {} }

    assert_response :forbidden
  end

  test "memeber should not get edit" do
    users(:edu).update!(role: "member")

    get edit_project_project_assignment_url(@project, @project_assignment)
    assert_response :forbidden
  end

  test "memeber should not update project" do
    users(:edu).update!(role: "member")

    patch project_project_assignment_path(@project, @project_assignment),
          params: { project_assignment: {} }

    assert_response :forbidden
  end

  test "memeber should not destroy project" do
    users(:edu).update!(role: "member")

    assert_no_difference("ProjectAssignment.count") do
      delete project_project_assignment_url(@project, @project_assignment)
    end

    assert_response :forbidden
  end

  test "search by user" do
    sign_in users(:edu)
    get new_project_project_assignment_url(@project)

    assert_match /Franco/, @response.body
    assert_match /Edu/, @response.body

    get users_url, params: { q: { first_name_or_last_name_or_email_cont: "Edu" } }
    get new_project_project_assignment_url(@project), params: { q: { first_name_or_last_name_or_email_cont: "Edu" } }

    assert_response :success

    assert_no_match /Franco/, @response.body
    assert_match /Edu/, @response.body
  end
end
