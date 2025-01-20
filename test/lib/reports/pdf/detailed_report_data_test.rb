require "test_helper"

class Reports::Pdf::DetailedReportDataTest < ActiveSupport::TestCase
  setup do
    @manager = users(:franco)

    # == Clients
    @client_plum = clients(:plum)

    # == Projects
    @project_plum_www = projects(:one)

    # == Users
    [ "alan", "grace", "linus" ].each do |name|
      User.create!(first_name: name, last_name: "plum", email_address: "#{name}@plum.com.ar", password: "123456")
    end

    # == Assign user to projects
    @project_plum_www.project_assignments.create!(user: User.find_by(first_name: "alan"), role: :member)

    # == Assign manager to project
    @project_plum_www.project_assignments.create!(user: @manager, role: :manager)

    # == Time entries
    start_date = Date.current.beginning_of_month
    end_date = Date.current.end_of_month

    # No project
    TimeEntry.create!(
      date: start_date + 1.day, duration_minutes: 20, user: User.find_by(first_name: "alan"), description: "Test"
    )
    TimeEntry.create!(
      date: start_date + 1.day, duration_minutes: 50, user: User.find_by(first_name: "grace"), description: "Test"
    )

    # Plum project
    TimeEntry.create!(
      date: start_date + 1.day, duration_minutes: 20, user: User.find_by(first_name: "alan"), description: "Test",
      project: @project_plum_www
    )

    @filter = Report::DetailedFilter.new(
      start_date: start_date,
      end_date: end_date,
      current_user: @manager
    )

    @data = Reports::Pdf::DetailedReportData.new(@filter)
  end

  test "delegates missing methods to filter" do
    assert_equal @filter.start_date, @data.start_date
    assert_equal @filter.end_date, @data.end_date
    assert_equal @filter.total_minutes, @data.total_minutes
    assert_equal @filter.results, @data.results
  end

  test "calculates total hours" do
    assert_equal "0h 20m", @data.total_hours
  end

  test "groups results by project" do
    grouped_results = @data.grouped_by_project_results

    assert_kind_of Array, grouped_results
    assert_equal 1, grouped_results.size

    # plum project
    group = grouped_results.first
    assert_equal @project_plum_www.name, group[:project_name]
    assert_equal "0h 20m", group[:group_duration]
    assert_equal 1, group[:results].size
  end

  test "handles empty results" do
    TimeEntry.destroy_all

    grouped_results = @data.grouped_by_project_results

    assert_empty grouped_results
    assert_equal "0h 0m", @data.total_hours
    assert_equal 0, grouped_results.size
  end
end
