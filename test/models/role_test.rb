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
end
