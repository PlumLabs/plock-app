require "test_helper"

class TimeEntryTest < ActiveSupport::TestCase
  test "should save valid time entry" do
    assert TimeEntry.new(user: users(:edu), date: Date.current, hours: 8, description: "time entry tests").valid?
  end
  test "should save time entry without project" do
    assert TimeEntry.new(user: users(:edu), date: Date.current, hours: 8, description: "t").valid?
  end

  test "should not save time entry without user" do
    assert_not TimeEntry.new(date: Date.current, hours: 8, description: "t").valid?
  end

  test "should not save time entry without date" do
    assert_not TimeEntry.new(user: users(:edu), hours: 8, description: "t").valid?
  end

  test "should not save time entry without hours" do
    assert_not TimeEntry.new(user: users(:edu), date: Date.current, description: "t").valid?
  end

  test "should not save time entry with negative hours" do
    assert_not TimeEntry.new(hours: -1, user: users(:edu), date: Date.current, description: "t").valid?
  end
end
