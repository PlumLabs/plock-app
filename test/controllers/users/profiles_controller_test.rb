require "test_helper"

class Users::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:edu)
  end

  test "members can update their own profile" do
    user = users(:edu)

    patch user_profile_path(user), params: { user: { first_name: "Darth", last_name: "Vader"  } }

    assert_redirected_to edit_user_profile_path(user)
    assert_equal "Updated", flash[:notice]

    user.reload
    assert_equal "Darth Vader", user.name
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

  test "members are not allowed to destroy the user profile" do
    user = users(:edu)
    user.update!(role: :member)

    delete user_path(user)

    assert_response :forbidden
  end

  test "members are not allowed to change the role" do
    user = users(:edu)
    user.update!(role: :member)

    patch user_profile_path(user), params: { user: { role: "administrator" } }

    assert_response :redirect
    assert_equal users(:edu).reload.role, "member"
  end

  test "members are not allowed to change the email" do
    user = users(:edu)
    user.update!(role: :member)

    patch user_profile_path(user), params: { user: { email_address: "rails@plum.com.ar" } }

    assert_response :redirect
    assert_equal users(:edu).reload.email_address, "edu@plum.com.ar"
  end

  test "admins are allowed to update other users profiles" do
    user = users(:franco)

    patch user_profile_path(user), params: { user: { first_name: "Darth", role: "administrator" } }

    assert_response :redirect

    user.reload
    assert_equal "Darth", user.first_name
  end
end
