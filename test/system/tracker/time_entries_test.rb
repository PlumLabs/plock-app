require "application_system_test_case"

class Tracker::TimeEntriesTest < ApplicationSystemTestCase
  test "tracking a new time" do
    sign_in users(:franco).email_address
    visit tracker_url

    within("#add-time") do
      fill_in "Description", with: "Adding test for time tracking"
      fill_in "Duration", with: "00:35"
      click_on "Add time"
    end

    assert_text "Successfully created!"
  end

  test "updating a time entry" do
    sign_in users(:franco).email_address
    time_entry = time_entries(:one)

    visit tracker_url

    within("##{dom_id(time_entry)}") do
      fill_in "Description", with: "GPT-5 upgrade"
      fill_in "Duration", with: "01:12"
      click_on "Update"
    end

    assert_text "Successfully Updated!"
    assert time_entry.reload.description, "GPT-5 upgrade"
    assert time_entry.reload.duration, "01:12"
  end

  test "removing a time entry" do
    sign_in users(:franco).email_address
    time_entry = time_entries(:one)

    visit tracker_url

    within("##{dom_id(time_entry)}") do
      accept_confirm do
        click_on "Delete"
      end
    end

    assert_text "Successfully destroyed!"
    assert_no_selector "##{dom_id(time_entry)}"
  end
end
