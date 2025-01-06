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

  test "time entries are paginated" do
    10.times do
      TimeEntry.create!(
        user: users(:edu),
        duration_minutes: rand(120..240),
        description: "test",
        date: Faker::Date.between(from: 3.months.ago, to: Date.today)
      )
    end

    sign_in users(:edu)

    get tracker_url, params: { per_page: 3 }
    assert_select "a", { text: /Next/ }
    assert_select "a", { text: /Previous/, count: 0 }

    # Navigate to the second page to test the presence of the "Previous" link
    get tracker_url, params: { page: 2, per_page: 3 }
    assert_select "a", { text: /Next/ }
    assert_select "a", { text: /Previous/ }
  end

  test "does not show pagination when no enough records" do
    sign_in users(:edu)

    get tracker_url
    assert_select "a", { text: /Previous/, count: 0 }
    assert_select "a", { text: /Next/, count: 0 }
  end
end
