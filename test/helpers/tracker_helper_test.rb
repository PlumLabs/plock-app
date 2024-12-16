require "test_helper"

class TrackerHelperTest < ActionView::TestCase
  test "#minutes_to_hours returns a human version of minutes in hours" do
    assert_equal "1h 30m", minutes_to_hours(90)
    assert_equal "0h 0m", minutes_to_hours(0)
  end
end
