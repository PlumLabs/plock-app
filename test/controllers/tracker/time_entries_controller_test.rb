require "test_helper"

class Tracker::TimeEntriesControllerTest < ActionDispatch::IntegrationTest
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

  test "member cannot create/update a time entry for another user" do
    sign_in users(:franco)

    assert_no_difference("TimeEntry.count") do
      post tracker_time_entries_url, params: {
        time_entry: { date: "2021-05-01", description: "Worked on the project", duration: "03:34", user_id: users(:edu).id }
      }
    end
  end

  test "admin can destroy a time entry for another users" do
    time_entry = TimeEntry.create!(date: "2021-05-01", description: "Worked on the project", duration: "03:34", user: users(:franco))

    sign_in users(:edu)

    assert_difference("TimeEntry.count", -1) do
      delete tracker_time_entry_url(time_entry)
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

    assert_difference("TimeEntry.count", -1) do
      delete tracker_time_entry_url(time_entry)
    end
  end
end
