require "test_helper"

class Tracker::TimeEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    projects(:two).project_assignments.create!(user: users(:franco), role: :manager)
    projects(:two).project_assignments.create!(user: users(:edu), role: :member)
  end

  test "logged out users cannot manipulate time entries" do
    post tracker_time_entries_url, params: {
      time_entry: { date: "2021-05-01", description: "Worked on the project", duration: "03:34", user_id: users(:franco).id }
    }
    assert_redirected_to new_session_url

    patch tracker_time_entry_url(time_entries(:one)), params: { time_entry: {} }
    assert_redirected_to new_session_url

    delete tracker_time_entry_url(time_entries(:one))
    assert_redirected_to new_session_url
  end

  test "users can create time entries" do
    sign_in users(:franco)

    assert_difference("TimeEntry.count") do
      post tracker_time_entries_url, params: {
        time_entry: { date: "2021-05-01", description: "Worked on the project", duration: "03:34", user_id: users(:franco).id }
      }
    end
  end

  test "users cannot create/update a time entry for another user" do
    sign_in users(:franco)

    assert_no_difference("TimeEntry.count") do
      post tracker_time_entries_url, params: {
        time_entry: { date: "2021-05-01", description: "Worked on the project", duration: "03:34", user_id: users(:edu).id }
      }
    end
  end

  test "project manager can update a time entry for another user in the same project" do
    time_entry = TimeEntry.create!(date: "2021-05-01", description: "test", duration: "03:34", user: users(:edu), project: projects(:two))

    sign_in users(:franco)

    patch tracker_time_entry_url(time_entry), params: {
      time_entry: { date: "2022-02-02", description: "test", duration: "03:34", user_id: users(:edu).id, project_id: projects(:two).id }
    }

    time_entry.reload
    assert_equal time_entry.date, "2022-02-02".to_date
  end

  test "admin can destroy a time entry for another users" do
    time_entry = TimeEntry.create!(date: "2021-05-01", description: "Worked on the project", duration: "03:34", user: users(:franco))

    sign_in users(:edu)

    assert_difference("TimeEntry.count", -1) do
      delete tracker_time_entry_url(time_entry)
    end
  end

  test "project manager can destroy a time entry for another user in the same project" do
    no_project_time_entry = TimeEntry.create!(date: "2021-05-01", description: "test", duration: "03:34", user: users(:edu))
    project_time_entry = TimeEntry.create!(date: "2021-05-01", description: "test", duration: "03:34", user: users(:edu), project: projects(:two))

    sign_in users(:franco)

    assert_difference("TimeEntry.count", -1) do
      delete tracker_time_entry_url(project_time_entry)
    end

    assert_no_difference("TimeEntry.count") do
      delete tracker_time_entry_url(no_project_time_entry)
    end
  end

  test "memeber cannot destroy a time entry from another user" do
    time_entry = TimeEntry.create!(date: "2021-05-01", description: "Worked on the project", duration: "03:34", user: users(:edu))

    sign_in users(:franco)

    assert_no_difference("TimeEntry.count") do
      delete tracker_time_entry_url(time_entry)
    end
  end

  test "memeber can desotry its own time entries" do
    time_entry = TimeEntry.create!(date: "2021-05-01", description: "Worked on the project", duration: "03:34", user: users(:franco))

    sign_in users(:franco)

    assert TimeEntry.count, 1

    assert_difference("TimeEntry.count", 0) do
      delete tracker_time_entry_url(time_entry)
    end
  end
end
