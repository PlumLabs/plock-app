require "test_helper"

class Report::DetailedFilterTest < ActiveSupport::TestCase
  setup do
    # Admin and manager users
    @admin_user = users(:edu)
    @manager = users(:franco)

    # == Clients
    @client_plum = clients(:plum)
    @client_unassigned = Client.create!(name: "Google")
    @client_openia = Client.create!(name: "OpenIA")

    # == Projects
    @project_plum_www = projects(:one)
    @project_openia_gpt5 = Project.create!(name: "GPT-5", client: @client_openia)
    @project_unassigned = Project.create!(name: "Unassigned")

    # == Users
    [ "alan", "grace", "linus" ].each do |name|
      User.create!(first_name: name, last_name: "plum", email_address: "#{name}@plum.com.ar", password: "123456")
    end

    # == Assign user to projects
    @project_plum_www.project_assignments.create!(user: User.find_by(first_name: "alan"), role: :member)
    @project_openia_gpt5.project_assignments.create!(user: User.find_by(first_name: "grace"), role: :member)
    @project_unassigned.project_assignments.create!(user: User.find_by(first_name: "linus"), role: :member)

    # == Assign manager to project
    @project_openia_gpt5.project_assignments.create!(user: @manager, role: :manager)
  end

  test "defaults start and end date to the current month" do
    filter = Report::DetailedFilter.new
    assert_equal Date.today.beginning_of_month, filter.start_date
    assert_equal Date.today.end_of_month, filter.end_date
  end

  test "aliases mobile attributes correctly" do
    filter = Report::DetailedFilter.new(
      user_ids: [ 1, 2 ],
      project_ids: [ 3, 4 ],
      client_ids: [ 5, 6 ]
    )

    assert_equal filter.user_ids, filter.mobile_user_ids
    assert_equal filter.project_ids, filter.mobile_project_ids
    assert_equal filter.client_ids, filter.mobile_client_ids
  end

  test "admin user sees all clients" do
    filter = Report::DetailedFilter.new(current_user: @admin_user)
    assert_equal Client.order(name: :asc).to_sql, filter.clients.to_sql
  end

  test "manager user sees only clients from projects that manage" do
    filter = Report::DetailedFilter.new(current_user: @manager)

    assert_includes filter.clients, @project_openia_gpt5.client
    assert_not_includes filter.clients, @client_plum
    assert_not_includes filter.clients, @client_unassigned
  end

  test "admin user sees all projects" do
    filter = Report::DetailedFilter.new(current_user: @admin_user)
    assert_equal Project.order(name: :asc).to_sql, filter.projects.to_sql
  end

  test "manager user sees only projects that manage" do
    filter = Report::DetailedFilter.new(current_user: @manager)

    assert_includes filter.projects, @project_openia_gpt5
    assert_not_includes filter.projects, @project_plum_www
    assert_not_includes filter.projects, @project_unassigned
  end

  test "admin user sees all users" do
    filter = Report::DetailedFilter.new(current_user: @admin_user)
    assert_equal User.order(first_name: :asc, last_name: :asc).to_sql, filter.users.to_sql
  end

  test "manager user sees only users from project that manage" do
    filter = Report::DetailedFilter.new(current_user: @manager)

    assert_includes filter.users, User.find_by(first_name: "grace")
    assert_not_includes filter.users, User.find_by(first_name: "alan")
    assert_not_includes filter.users, User.find_by(first_name: "linus")
  end

  test "filters handle empty arrays" do
    filter = Report::DetailedFilter.new(
      current_user: @admin_user,
      user_ids: [],
      project_ids: [],
      client_ids: []
    )

    assert_nothing_raised { filter.results }
  end

  test "filters by date range" do
    start_date = Date.today.beginning_of_month.last_year
    end_date = Date.today.end_of_month.last_year


    filter = Report::DetailedFilter.new(current_user: @admin_user, start_date: start_date, end_date: end_date)

    assert_equal filter.results, []

    entry = TimeEntry.create!(
      date: start_date + 1.day, duration_minutes: 60, user: User.find_by(first_name: "alan"), description: "Test"
    )

    assert_equal filter.results, [ entry ]
  end

  test "calculates total minutes" do
    filter = Report::DetailedFilter.new(current_user: @admin_user)
    assert_equal filter.total_minutes, 0

    TimeEntry.create!(date: Date.today, duration_minutes: 30, user: User.find_by(first_name: "alan"), description: "Test 1")
    TimeEntry.create!(date: Date.today, duration_minutes: 30, user: User.find_by(first_name: "alan"), description: "Test 2")
    assert_equal filter.total_minutes, 60
  end
end
