require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "member users are not allowed to the index" do
    users(:edu).update!(role: :member)
    sign_in users(:edu)

    get users_url
    assert_response :forbidden
  end

  test "administrator users are allow to the index" do
    sign_in users(:edu)

    get users_url
    assert_response :success
  end
end
