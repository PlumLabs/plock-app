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

  test "should not update a user profile with invalid data" do
    user = users(:edu)

    patch user_profile_path(user), params: { user: { first_name: "" } }

    assert_response :unprocessable_entity
  end
end
