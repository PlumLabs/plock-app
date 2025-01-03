require "test_helper"

class ProjectAssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Project
    @project = projects(:two)

    # Users
    @admin_user = users(:edu)
    @project_manager = users(:franco)
    @project_member = User.create!(
      first_name: "Alan",
      last_name: "Turing",
      email_address: "aturing@plum.com.ar",
      password: "password",
      role: :member
    )

    # Project Assignments
    @project.project_assignments.create!(user: @project_manager, role: :manager)
    @project_assignment = @project.project_assignments.create!(user: @project_member, role: :member)
  end

  test "administrator should get new" do
    sign_in @admin_user
    get new_project_project_assignment_url(@project)
    assert_response :success
  end

  test "manager should get new" do
    sign_in @project_manager
    get new_project_project_assignment_url(@project)
    assert_response :success
  end

  test "memeber should not get new" do
    sign_in @project_member
    get new_project_project_assignment_url(@project)
    assert_response :forbidden
  end

  test "administrator should create a project assignment" do
    sign_in @admin_user

    assert_difference("ProjectAssignment.count") do
      post project_project_assignments_path(@project), params: { project_assignment: { user_id: users(:edu).id } }
    end

    assert_redirected_to project_url(@project)
  end

  test "project manager should create a project assignment" do
    sign_in @project_manager

    assert_difference("ProjectAssignment.count") do
      post project_project_assignments_path(@project), params: { project_assignment: { user_id: users(:edu).id } }
    end

    assert_redirected_to project_url(@project)
  end

  test "memeber should not create project" do
    sign_in @project_member

    post project_project_assignments_path(@project), params: { project_assignment: {} }

    assert_response :forbidden
  end

  test "administrator should get edit" do
    sign_in @admin_user
    get edit_project_project_assignment_url(@project, @project_assignment)
    assert_response :success
  end

  test "project manager should get edit" do
    sign_in @project_manager
    get edit_project_project_assignment_url(@project, @project_assignment)
    assert_response :success
  end

  test "memeber should not get edit" do
    sign_in @project_member

    get edit_project_project_assignment_url(@project, @project_assignment)
    assert_response :forbidden
  end

  test "administrator should update a project assignment" do
    sign_in @admin_user
    patch project_project_assignment_path(@project, @project_assignment),
          params: { project_assignment: { role: "manager" } }

    assert_redirected_to project_url(@project)
  end

  test "project manager should update a project assignment" do
    sign_in @project_manager
    patch project_project_assignment_path(@project, @project_assignment),
          params: { project_assignment: { role: "manager" } }

    assert_redirected_to project_url(@project)
  end

  test "memeber should not update project" do
    sign_in @project_member

    patch project_project_assignment_path(@project, @project_assignment),
          params: { project_assignment: {} }

    assert_response :forbidden
  end

  test "administrator should destroy project assigment" do
    sign_in @admin_user
    assert_difference("ProjectAssignment.count", -1) do
      delete project_project_assignment_url(@project, @project_assignment)
    end

    assert_redirected_to project_url(@project)
  end

  test "project manager should destroy project assigment" do
    sign_in @project_manager
    assert_difference("ProjectAssignment.count", -1) do
      delete project_project_assignment_url(@project, @project_assignment)
    end

    assert_redirected_to project_url(@project)
  end

  test "memeber should not destroy project" do
    sign_in @project_member

    assert_no_difference("ProjectAssignment.count") do
      delete project_project_assignment_url(@project, @project_assignment)
    end

    assert_response :forbidden
  end

  test "search by user" do
    [ "grace", "linus" ].each do |name|
      User.create!(first_name: name, last_name: "plum", email_address: "#{name}@plum.com.ar", password: "123456")
    end

    sign_in @admin_user

    get new_project_project_assignment_url(@project)

    assert_match /Grace/, @response.body
    assert_match /Linus/, @response.body

    get new_project_project_assignment_url(@project), params: { q: { first_name_or_last_name_or_email_cont: "Linus" } }

    assert_response :success

    assert_no_match /Grace/, @response.body
    assert_match /Linus/, @response.body
  end
end
