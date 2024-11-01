require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "validates presence of first_name, last_name and email_address" do
    assert_not users(:edu).update(first_name: nil)
    assert_not users(:edu).update(last_name: nil)
    assert_not users(:edu).update(email_address: nil)
  end

  test "normalizes email_address" do
    user = users(:edu)
    user.update!(email_address: "EDU@PLUM.com.ar")
    assert_equal "edu@plum.com.ar", user.email_address
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
end
