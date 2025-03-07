require "application_system_test_case"

class Reports::DetailedsTest < ApplicationSystemTestCase
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
    alan_user = User.create!(first_name: "alan", last_name: "plum", email_address: "alan@plum.com.ar", password: "123456")
    grace_user = User.create!(first_name: "grace", last_name: "plum", email_address: "grace@plum.com.ar", password: "123456")
    linus_user = User.create!(first_name: "linus", last_name: "plum", email_address: "linus@plum.com.ar", password: "123456")

    # == Assign user to projects
    @project_plum_www.project_assignments.create!(user: alan_user, role: :member)
    @project_openia_gpt5.project_assignments.create!(user: grace_user, role: :member)
    @project_unassigned.project_assignments.create!(user: linus_user, role: :member)

    # == Assign manager to project
    @project_openia_gpt5.project_assignments.create!(user: @manager, role: :manager)

    # == Time entries
    TimeEntry.create!(date: Date.today, duration_minutes: 10, project: @project_plum_www, user: alan_user, description: "test-desc-1")
    TimeEntry.create!(date: Date.today - 1.year, duration_minutes: 20, project: @project_plum_www, user: alan_user, description: "test-desc-2")

    TimeEntry.create!(date: Date.today, duration_minutes: 30, project: @project_openia_gpt5, user: grace_user, description: "test-desc-3")
    TimeEntry.create!(date: Date.today - 1.year, duration_minutes: 40, project: @project_openia_gpt5, user: grace_user, description: "test-desc-4")

    TimeEntry.create!(date: Date.today, duration_minutes: 50, project: @project_unassigned, user: linus_user, description: "test-desc-5")
    TimeEntry.create!(date: Date.today - 1.year, duration_minutes: 60, project: @project_unassigned, user: linus_user, description: "test-desc-6")

    TimeEntry.create!(date: Date.today, duration_minutes: 70, user: linus_user, description: "test-desc-7")

    sign_in @admin_user.email_address
  end

  test "search on filters" do
    [ "Twitter", "Slack", "Microsoft", "KPMG" ].each do |client_name|
      Client.create!(name: client_name)
    end

    visit reports_detailed_url

    within('[data-test-id="clients-filter"]') do
      click_on "Clients"

      assert_text "Twitter"
      assert_text "Slack"
      assert_text "Microsoft"
      assert_text "KPMG"

      fill_in "Search for", with: "KPMG"

      assert_text "KPMG"
      assert_no_text "Twitter"
      assert_no_text "Slack"
    end

    within('[data-test-id="projects-filter"]') do
      click_on "Projects"

      # No many projects to allow the search
      assert_no_text "Search for"
    end

    within('[data-test-id="users-filter"]') do
      click_on "Users"

      # No many users to allow the search
      assert_no_text "Search for"
    end
  end

  test "filter by client" do
    visit reports_detailed_url

    within('[data-test-id="clients-filter"]') do
      click_on "Clients"
      check @client_plum.name
    end

    click_on "Apply Filters"

    within('[data-test-id="entries"]') do
      assert_text "Total: 0h 10m"
      assert_text "www site"
      assert_text "Alan Plum"

      assert_no_text "Grace Plum"
      assert_no_text "Linus Plum"
    end
  end

  test "filter by project" do
    visit reports_detailed_url

    within('[data-test-id="projects-filter"]') do
      click_on "Projects"
      check @project_openia_gpt5.name
    end

    click_on "Apply Filters"

    within('[data-test-id="entries"]') do
      assert_text "Total: 0h 30m"
      assert_text "GPT-5"
      assert_text "Grace Plum"

      assert_no_text "Alan Plum"
      assert_no_text "Linus Plum"
    end
  end

  test "filter by user" do
    visit reports_detailed_url

    within('[data-test-id="users-filter"]') do
      click_on "Users"
      check "Linus Plum"
    end

    click_on "Apply Filters"

    within('[data-test-id="entries"]') do
      assert_text "Total: 2h 0m"
      assert_text "Unassigned"
      assert_text "Project"
      assert_text "Linus Plum"

      assert_no_text "Alan Plum"
      assert_no_text "Grace Plum"
    end
  end

  test "filter by date" do
    visit reports_detailed_url

    start_date = Date.today - 1.year
    end_date = start_date + 1.day

    fill_in "report[start_date]", with: start_date
    fill_in "report[end_date]", with: end_date

    click_on "Apply Filters"

    within('[data-test-id="entries"]') do
      assert_text "Total: 2h 0m"
      assert_text "Linus Plum"
      assert_text "Alan Plum"
      assert_text "Grace Plum"
    end
  end

  test "generate a pdf report" do
    visit reports_detailed_url

    initial_window_count = windows.length

    pdf_report_window = window_opened_by do
      click_on "Open PDF Report"
    end

    assert_equal initial_window_count + 1, windows.length

    within_window(pdf_report_window) do
      assert_match(/\.pdf/, current_url)
    end

    pdf_report_window.close
  end

  test "add a new time entry for other user" do
    visit reports_detailed_url

    find("summary", text: "Add time for others").click

    within("#new_time_entry") do
      fill_in "Description", with: "Adding test for time tracking"
      fill_in "Duration", with: "00:35"
      select @project_plum_www.name, from: "time_entry[project_id]"
      select "Alan Plum", from: "time_entry[user_id]"
      click_on "Add time"
    end

    assert_text "Successfully created!"
  end

  # I'm Franco, a manager of the project "GPT-5" where Grace Plum is a member.
  # I shouldn't see the time entries of Gtace Plum from other projects.
  test "restuls are scope to the user role" do
    sign_out @admin_user

    grace = User.find_by(first_name: "grace")
    @project_plum_www.project_assignments.create!(user: grace, role: :member)
    TimeEntry.create!(date: Date.today, duration_minutes: 40, project: @project_plum_www, user: grace, description: "test-desc-4")

    sign_in @manager.email_address
    visit reports_detailed_url
    assert_text "Total: 0h 30m"
  end
end
