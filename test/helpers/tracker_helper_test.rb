require "test_helper"

class TrackerHelperTest < ActionView::TestCase
  test "#minutes_to_hours returns a human version of minutes in hours" do
    assert_equal "1h 30m", minutes_to_hours(90)
    assert_equal "0h 0m", minutes_to_hours(0)
  end

  test "#human_date_format returns a human version of a date" do
    assert_equal "Today", human_date_format(Date.today)
    assert_equal "Yesterday", human_date_format(Date.yesterday)
    assert_equal "January 01, 2021", human_date_format(Date.new(2021, 1, 1))
  end
end
