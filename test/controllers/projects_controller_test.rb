require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
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

  test "administrator should get index" do
    sign_in @admin_user
    get projects_url
    assert_response :success
  end

  test "project managers should get index" do
    sign_in @project_manager
    get projects_url
    assert_response :success
  end

  test "memeber should not get index" do
    sign_in @project_member
    get projects_url
    assert_response :forbidden
  end

  test "administrator should get new" do
    sign_in @admin_user
    get new_project_url
    assert_response :success
  end

  test "project managers should not get new" do
    sign_in @project_manager
    get new_project_url
    assert_response :forbidden
  end

  test "memeber should not get new" do
    sign_in @project_member
    get new_project_url
    assert_response :forbidden
  end

  test "administrator should create project" do
    sign_in @admin_user
    assert_difference("Project.count") do
      post projects_url, params: { project: { name: "HR assistant" } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "project managers should not create project" do
    sign_in @project_manager
    assert_no_difference("Project.count") do
      post projects_url, params: { project: {} }
    end

    assert_response :forbidden
  end

  test "memeber should not create project" do
    sign_in @project_member
    assert_no_difference("Project.count") do
      post projects_url, params: { project: {} }
    end

    assert_response :forbidden
  end

  test "administrator should get edit" do
    sign_in @admin_user
    get edit_project_url(@project)
    assert_response :success
  end

  test "project manager should get edit" do
    sign_in @project_manager
    get edit_project_url(@project)
    assert_response :success
  end

  test "memeber should not get edit" do
    sign_in @project_member

    get edit_project_url(@project)
    assert_response :forbidden
  end

  test "administrator should update project" do
    sign_in @admin_user
    patch project_url(@project), params: { project: { name: "New name" } }
    assert_redirected_to @project
  end

  test "project manager should update project" do
    sign_in @project_manager
    patch project_url(@project), params: { project: { name: "New name" } }
    assert_redirected_to @project
  end

  test "memeber should not update project" do
    sign_in @project_member
    patch project_url(@project), params: { project: {} }
    assert_response :forbidden
  end

  test "administrator should destroy project" do
    sign_in @admin_user
    assert_difference("Project.active.count", -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end

  test "project manager should not destroy project" do
    sign_in @project_manager
    assert_no_difference("Project.count") do
      delete project_url(@project)
    end

    assert_response :forbidden
  end

  test "memeber should not destroy project" do
    sign_in @project_member
    assert_no_difference("Project.count") do
      delete project_url(@project)
    end

    assert_response :forbidden
  end

  test "administrator filter by client" do
    sign_in @admin_user
    Project.create!(name: "HR assistant", client: clients(:plum))

    get projects_url

    assert_match /HR assistant/, @response.body
    assert_match /survillance/, @response.body

    get projects_url, params: { q: { name_or_clients_name_cont: "Plum" } }

    assert_response :success
    assert_no_match /survillance/, @response.body
    assert_match /HR assistant/, @response.body
  end

  test "administrator filter by status" do
    sign_in @admin_user
    Project.create!(name: "HR assistant", disabled_at: Time.zone.now, client: clients(:plum))
    Project.create!(name: "Delta", disabled_at: Time.zone.now)

    get projects_url, params: { q: { status_eq: "archive" } }

    assert_match /HR assistant/, @response.body

    get projects_url, params: { q: { status_eq: "archive", name_or_clients_name_cont: "plum" } }

    assert_response :success
    assert_no_match /Delta/, @response.body
    assert_match /HR assistant/, @response.body
  end

  test "project manager only see its projects" do
    sign_in @project_manager
    Project.create!(name: "HR assistant", disabled_at: Time.zone.now, client: clients(:plum))
    Project.create!(name: "Delta", disabled_at: Time.zone.now)

    get projects_url

    assert_match /survillance/, @response.body
    assert_no_match /HR assistant/, @response.body
    assert_no_match /Delta/, @response.body
  end
end
