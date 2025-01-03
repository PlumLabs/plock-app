require "test_helper"

class User::RoleTest < ActiveSupport::TestCase
  test "creating users makes them members by default" do
    assert User.create!(first_name: "Master", last_name: "Yoda", email_address: "user@example.com", password: "secret123456").member?
  end

  test "can_administrate?" do
    assert User.new(role: :administrator).can_administrate?

    assert_not User.new(role: :member).can_administrate?
    assert_not User.new.can_administrate?
  end

  test "can_manage_projects?" do
    user = User.create!(first_name: "Master", last_name: "Yoda", email_address: "user@example.com", password: "secret123456")
    assert_not user.can_manage_projects?

    projects(:one).project_assignments.create!(user: user, role: :member)
    assert_not user.reload.can_manage_projects?

    projects(:two).project_assignments.create!(user: user, role: :manager)
    assert user.reload.can_manage_projects?
  end

  test "can_manage_project?" do
    user = User.create!(first_name: "Master", last_name: "Yoda", email_address: "user@example.com", password: "secret123456")
    assert_not user.can_manage_project?(projects(:one).id)

    projects(:one).project_assignments.create!(user: user, role: :member)
    assert_not user.reload.can_manage_project?(projects(:one).id)

    projects(:two).project_assignments.create!(user: user, role: :manager)
    assert user.reload.can_manage_project?(projects(:two).id)
  end
end
