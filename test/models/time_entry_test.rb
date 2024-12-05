require "test_helper"

class TimeEntryTest < ActiveSupport::TestCase
  test "should save valid time entry" do
    assert TimeEntry.new(user: users(:edu), date: Date.current, duration_minutes: 8.hours.in_minutes, description: "time entry tests").valid?
  end
  test "should save time entry without project" do
    assert TimeEntry.new(user: users(:edu), date: Date.current, duration_minutes: 8.hours.in_minutes, description: "t").valid?
  end

  test "should not save time entry without user" do
    assert_not TimeEntry.new(date: Date.current, duration_minutes: 8.hours.in_minutes, description: "t").valid?
  end

  test "should not save time entry without date" do
    assert_not TimeEntry.new(user: users(:edu), duration_minutes: 8.hours.in_minutes, description: "t").valid?
  end

  test "should not save time entry without duration_minutes" do
    assert_not TimeEntry.new(user: users(:edu), date: Date.current, description: "t").valid?
  end

  test "should not save time entry with negative duration_minutes" do
    assert_not TimeEntry.new(duration_minutes: -1, user: users(:edu), date: Date.current, description: "t").valid?
  end

  test "should not save time entry when user doesn't belongs to the project" do
    assert_not TimeEntry.new(user: users(:edu), date: Date.current, duration_minutes: 8.hours.in_minutes, description: "t", project: projects(:two)).valid?
  end

  test "returns duration with a format hh:mm" do
    time_entry = TimeEntry.new(duration_minutes: 8.hours.in_minutes)
    assert_equal "08:00", time_entry.duration
  end

  test "sets duration_minutes from duration" do
    time_entry = TimeEntry.new(duration: "08:25")
    assert_equal 8.hours.in_minutes + 25, time_entry.duration_minutes
  end

  test "returns duration_mobile with a time format" do
    time_entry = TimeEntry.new(duration_minutes: 8.hours.in_minutes)
    assert_equal Time.zone.local(2000, 1, 1, 8, 0, 0), time_entry.duration_mobile
  end

  test "sets duration_minutes from duration_mobile" do
    time = {
      "duration_mobile(1i)": "2000",
      "duration_mobile(2i)": "1",
      "duration_mobile(3i)": "1",
      "duration_mobile(4i)": "08",
      "duration_mobile(5i)": "25"
    }

    time_entry = TimeEntry.new(duration_mobile: time)
    assert_equal 8.hours.in_minutes + 25, time_entry.duration_minutes
  end
end
