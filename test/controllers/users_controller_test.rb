require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "members are not allow to see all users" do
    users(:edu).update!(role: :member)
    sign_in users(:edu)

    get users_url
    assert_response :forbidden
  end

  test "administrators are allow to see all users" do
    sign_in users(:edu)

    get users_url
    assert_response :success
  end

  test "members are not allow to create users" do
    users(:edu).update!(role: :member)
    sign_in users(:edu)

    post users_url, params: { user: {} }
    assert_response :forbidden
  end
end
