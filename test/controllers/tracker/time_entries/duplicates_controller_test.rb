require "test_helper"

class Tracker::TimeEntries::DuplicatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    projects(:two).project_assignments.create!(user: users(:franco), role: :manager)
  end

  test "logged out users cannot duplicate time entry" do
    post tracker_time_entry_duplicate_url(time_entries(:one).id)

    assert_redirected_to new_session_url
  end

  test "user can duplicates a time entries" do
    sign_in users(:franco)

    time_entry_initial_count = TimeEntry.count
    post tracker_time_entry_duplicate_url(time_entries(:one).id)
    assert TimeEntry.count, time_entry_initial_count + 1
  end

  test "administrator can duplicates time entries for another user" do
    sign_in users(:edu)

    time_entry_initial_count = TimeEntry.count
    post tracker_time_entry_duplicate_url(time_entries(:one).id)
    assert TimeEntry.count, time_entry_initial_count + 1
  end

  test "project manager cannot duplicates a time entry for other user in another project" do
    time_entry = TimeEntry.create!(date: "2021-05-01", description: "test", duration: "03:34", user: users(:edu))

    sign_in users(:franco)

    assert_no_difference("TimeEntry.count") do
      post tracker_time_entry_duplicate_url(time_entry.id)
    end

    assert_response :forbidden
  end

  test "project manager can duplicates a time entry for other user in the project" do
    user = User.create!(first_name: "alan", last_name: "plum", email_address: "linus@plum.com.ar", password: "password")
    projects(:two).project_assignments.create!(user: user, role: :member)
    time_entry = TimeEntry.create!(date: "2021-05-01", description: "test", duration: "03:34", user: user, project: projects(:two))

    sign_in users(:franco)

    assert_difference("TimeEntry.count", 1) do
      post tracker_time_entry_duplicate_url(time_entry.id)
    end
  end

  test "members cannot duplicate a time entry for another user in the same project" do
    user = User.create!(first_name: "alan", last_name: "plum", email_address: "linus@plum.com.ar", password: "password")
    projects(:two).project_assignments.create!(user: user, role: :member)
    time_entry = TimeEntry.create!(date: "2021-05-01", description: "test", duration: "03:34", user: users(:franco), project: projects(:two))

    sign_in user

    assert_no_difference("TimeEntry.count") do
      post tracker_time_entry_duplicate_url(time_entry.id)
    end

    assert_response :forbidden
  end
end
