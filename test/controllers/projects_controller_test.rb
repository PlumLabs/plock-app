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

  test "projects are paginated" do
    10.times { Project.create!(name: Faker::App.unique.name) }

    sign_in @admin_user

    get projects_url, params: { per_page: 5 }
    assert_select "a", { text: /Next/ }
    assert_select "a", { text: /Previous/, count: 0 }

    # Navigate to the second page to test the presence of the "Previous" link
    get projects_url, params: { page: 2, per_page: 5 }
    assert_select "a", { text: /Next/ }
    assert_select "a", { text: /Previous/ }
  end

  test "does not show pagination when no enough records" do
    sign_in @admin_user

    get projects_url
    assert_select "a", { text: /Previous/, count: 0 }
    assert_select "a", { text: /Next/, count: 0 }
  end

  test "project shows top contributors and allow to filter" do
    last_month = 1.month.ago.to_date.strftime("%Y-%m")
    5.times do
      TimeEntry.create!(
        user: @project_manager,
        project: @project,
        duration_minutes: 100,
        description: "test",
        date: Date.today
      )

      TimeEntry.create!(
        user: @project_member,
        project: @project,
        duration_minutes: 10,
        description: "test",
        date: 1.month.ago.to_date
      )
    end

    sign_in @project_manager
    get project_url(@project, anchor: "status")

    assert_dom "#top_contribution" do |elements|
      text_elements = elements.first.text
      # Assert for Franco (project manager) - 500 minutes total
      assert_match /Franco/, text_elements
      assert_match /8h 20m/, text_elements

      # Assert for Alan (project member) - 50 minutes total
      assert_match /Alan/, text_elements
      assert_match /50m/, text_elements

      assert text_elements.index("Franco") < text_elements.index("Alan"), "Franco should be listed before Alan as a top contributor"
    end

    # Test filtering by month
    get project_url(@project, start_month: last_month, anchor: "status")
    assert_response :success

    assert_dom "#top_contribution" do |elements|
      text_elements = elements.first.text

      assert_no_match /Franco/, text_elements
      assert_match /Alan/, text_elements
      assert_match /50m/, text_elements #
    end
  end

  test "project shows % all contributions" do
    5.times do
      TimeEntry.create!(
        user: @project_manager,
        project: @project,
        duration_minutes: 100,
        description: "test",
        date: Date.today
      )

      TimeEntry.create!(
        user: @project_member,
        project: @project,
        duration_minutes: 10,
        description: "test",
        date: Date.today
      )
    end

    sign_in @project_manager
    get project_url(@project, anchor: "status")

    # Assert for Franco (project manager) - 500 minutes total
    assert_match /Franco/, @response.body
    assert_match /90.91/, @response.body

    # Assert for Alan (project member) - 50 minutes total
    assert_match /Alan/, @response.body
    assert_match /9.09/, @response.body
  end
end
