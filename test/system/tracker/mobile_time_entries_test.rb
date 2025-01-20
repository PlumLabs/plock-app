require "mobile_system_test_case"

class Tracker::MobileTimeEntriesTest < MobileSystemTestCase
  test "tracking a new time" do
    sign_in users(:franco).email_address
    visit tracker_url

    within("#new_time_entry") do
      fill_in "Description", with: "Adding test for time tracking"
      select "01", from: "time_entry[duration_mobile(4i)]"
      select "25", from: "time_entry[duration_mobile(5i)]"
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
      select "08", from: "time_entry[duration_mobile(4i)]"
      select "25", from: "time_entry[duration_mobile(5i)]"
      click_on "Update"
    end

    assert_text "Successfully updated!"
    assert time_entry.reload.description, "GPT-5 upgrade"
    assert time_entry.reload.duration, "08:25"
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

  test "duplicating a time entry" do
    time_entry = time_entries(:one)

    sign_in users(:franco).email_address

    visit tracker_url

    assert_text "Total: 3h 15m"

    within("##{dom_id(time_entry)}") do
      click_on "Duplicate"
    end

    assert_text "Total: 6h 30m"
  end
end
