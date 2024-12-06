require "test_helper"

class TrackerControllerTest < ActionDispatch::IntegrationTest
  test "logged in user should get the tracker" do
    sign_in users(:edu)

    get tracker_url
    assert_response :success
  end

  test "not logged in user should not get the tracker" do
    get tracker_url
    assert_response :redirect
  end
end
