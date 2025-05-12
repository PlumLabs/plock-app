require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "validates presence of name" do
    assert_not projects(:one).update(name: nil)
  end

  test "#disable! sets disabled_at" do
    project = projects(:one)
    assert_nil project.disabled_at
    project.disable!
    assert_not_nil project.disabled_at
  end

  test ".active returns only active projects" do
    assert_equal 2, Project.active.count

    projects(:one).disable!

    assert_equal 1, Project.active.count
  end

  test ".archive returns only archive projects" do
    assert_equal 0, Project.archive.count

    projects(:one).disable!

    assert_equal 1, Project.archive.count
  end

  test "#total_minutes_tracked returns sum of time entry durations" do
    project = projects(:one)
    user = users(:edu)

    TimeEntry.create!(project: project, user: user, duration_minutes: 30, date: Date.today, description: "Test entry 1")
    TimeEntry.create!(project: project, user: user, duration_minutes: 15, date: Date.today, description: "Test entry 2")
    TimeEntry.create!(user: user, duration_minutes: 15, date: Date.today, description: "Test entry 3")

    assert_equal 45, project.total_minutes_tracked
  end
end
