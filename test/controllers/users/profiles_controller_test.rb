require "test_helper"

class Users::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:edu)
  end

  test "should update a user profile" do
    user = users(:edu)

    patch user_profile_path(user), params: { user: { first_name: "Darth" } }

    assert_redirected_to edit_user_profile_path(user)
    assert_equal "Updated", flash[:notice]

    user.reload
    assert_equal "Darth", user.first_name
  end

  test "members are not allowed to update other users profiles" do
    users(:edu).update!(role: :member)

    user = users(:franco)

    patch user_profile_path(user), params: { user: { first_name: "Darth" } }

    assert_response :forbidden
  end

  test "members are not allowed to deactivate the user profile" do
    user = users(:edu)
    user.update!(role: :member)

    delete user_profile_url(user)

    assert_response :forbidden
  end

  test "admins are allowed to update other users profiles" do
    user = users(:franco)

    patch user_profile_path(user), params: { user: { first_name: "Darth" } }

    assert_response :redirect

    user.reload
    assert_equal "Darth", user.first_name
  end
end
