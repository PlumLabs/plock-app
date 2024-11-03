require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "validates presence of first_name, last_name and email_address" do
    assert_not users(:edu).update(first_name: nil)
    assert_not users(:edu).update(last_name: nil)
    assert_not users(:edu).update(email_address: nil)
  end

  test "unique email_address" do
    existing_user = users(:edu)
    assert_not User.create(email_address: existing_user.email_address, first_name: "Franco", last_name: "Plum", password: "password").valid?
  end

  test "normalizes email_address" do
    user = users(:edu)
    user.update!(email_address: "EDU@PLUM.com.ar")
    assert_equal "edu@plum.com.ar", user.email_address
  end

  test "scope active" do
    User.create!(first_name: "Inactive", last_name: "User", email_address: "inactive@plum.com.ar", password: "password", inactive_at: Time.current)

    active_user = users(:edu)

    assert_equal User.active.ids, [ active_user.id ]
  end

  test "#current?" do
    # Current user is not edu
    user = User.new(first_name: "Edu", last_name: "Plum", email_address: "saul@plum.com.ar", password: "password")
    session = Session.new(user: user)

    Current.session = session

    edu = users(:edu)
    assert_not edu.current?

    # Current user is edu
    session.user = edu
    assert edu.current?
  end

  test "#name" do
    user = User.new(first_name: "edu", last_name: "depetris")
    assert_equal "Edu Depetris", user.name
  end

  test "#deactivate" do
    user = users(:edu)
    assert user.active?

    user.deactivate
    assert_not user.active?
  end
end
