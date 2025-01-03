require "test_helper"

class TimeUtilTest < ActiveSupport::TestCase
  include TimeUtil

  test "converts zero minutes" do
    assert_equal "0h 0m", minutes_to_hours(0)
  end

  test "converts full hours" do
    assert_equal "2h 0m", minutes_to_hours(120)
  end

  test "converts hours and minutes" do
    assert_equal "2h 30m", minutes_to_hours(150)
  end

  test "accepts custom format" do
    assert_equal "02:30", minutes_to_hours(150, "%02d:%02d")
  end
end
