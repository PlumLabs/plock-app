require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    sign_in users(:edu)
  end

  test "administrator should get index" do
    get projects_url
    assert_response :success
  end

  test "administrator should get new" do
    get new_project_url
    assert_response :success
  end

  test "administrator should create project" do
    assert_difference("Project.count") do
      post projects_url, params: { project: { name: "HR assistant" } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "administrator should get edit" do
    get edit_project_url(@project)
    assert_response :success
  end

  test "administrator should update project" do
    patch project_url(@project), params: { project: { name: "New name" } }
    assert_redirected_to @project
  end

  test "administrator should destroy project" do
    assert_difference("Project.active.count", -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end

  test "memeber should not get index" do
    users(:edu).update!(role: "member")

    get projects_url
    assert_response :forbidden
  end

  test "memeber should not get new" do
    users(:edu).update!(role: "member")

    get new_project_url
    assert_response :forbidden
  end

  test "memeber should not create project" do
    users(:edu).update!(role: "member")

    assert_no_difference("Project.count") do
      post projects_url, params: { project: {} }
    end

    assert_response :forbidden
  end

  test "memeber should not get edit" do
    users(:edu).update!(role: "member")

    get edit_project_url(@project)
    assert_response :forbidden
  end

  test "memeber should not update project" do
    users(:edu).update!(role: "member")

    patch project_url(@project), params: { project: {} }
    assert_response :forbidden
  end

  test "memeber should not destroy project" do
    users(:edu).update!(role: "member")

    assert_no_difference("Project.count") do
      delete project_url(@project)
    end

    assert_response :forbidden
  end

  test "filter by client" do
    Project.create!(name: "HR assistant", client: clients(:plum))

    get projects_url

    assert_match /HR assistant/, @response.body
    assert_match /survillance/, @response.body

    get projects_url, params: { q: { name_or_clients_name_cont: "Plum" } }

    assert_response :success
    assert_no_match /survillance/, @response.body
    assert_match /HR assistant/, @response.body
  end

  test "filter by status" do
    Project.create!(name: "HR assistant", disabled_at: Time.zone.now, client: clients(:plum))
    Project.create!(name: "Delta", disabled_at: Time.zone.now)

    get projects_url, params: { q: { status_eq: "archive" } }

    assert_match /HR assistant/, @response.body

    get projects_url, params: { q: { status_eq: "archive", name_or_clients_name_cont: "plum" } }

    assert_response :success
    assert_no_match /Delta/, @response.body
    assert_match /HR assistant/, @response.body
  end
end
