require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "administrators are allow to see all users" do
    sign_in users(:edu)

    get users_url
    assert_response :success
  end

  test "search by user" do
    sign_in users(:edu)
    get users_url

    assert_match /Franco/, @response.body
    assert_match /Edu/, @response.body

    get users_url, params: { q: { first_name_or_last_name_or_email_cont: "Edu" } }

    assert_response :success
    assert_no_match /Franco/, @response.body
    assert_match /Edu/, @response.body
  end

  test "members are not allow to see all users" do
    users(:edu).update!(role: :member)
    sign_in users(:edu)

    get users_url
    assert_response :forbidden
  end

  test "members are not allow to create users" do
    users(:edu).update!(role: :member)
    sign_in users(:edu)

    post users_url, params: { user: {} }
    assert_response :forbidden
  end

  test "memers are not allow to destroy users" do
    users(:edu).update!(role: :member)
    sign_in users(:edu)

    delete user_url(users(:franco))
    assert_response :forbidden
  end

  test "filter by status" do
    users(:franco).update!(disabled_at: Time.zone.now)

    sign_in users(:edu)

    get users_url, params: { q: { status_eq: "archive" } }

    assert_match /Franco/, @response.body

    get users_url, params: { q: { status_eq: "active", first_name_or_last_name_or_email_cont: "edu" } }

    assert_no_match /Franco/, @response.body
    assert_match /Eduardo/, @response.body
  end

  test "users are paginated" do
    10.times do
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      email = Faker::Internet.unique.email(name: first_name, domain: "plum.com.ar")
      User.create!(email_address: email, first_name: first_name, last_name: last_name, password: "123456")
    end

    sign_in users(:edu)

    get users_url, params: { per_page: 5, keep_me: { pagination: "should-kep-this" } }
    assert_select "a[href=?]", users_path(per_page: 5, page: 2, keep_me: { pagination: "should-kep-this" }), text: /Next/
    assert_select "a", { text: /Previous/, count: 0 }

    # Navigate to the second page to test the presence of the "Previous" link
    get users_url, params: { page: 2, per_page: 5, keep_me: { pagination: "should-kep-this" } }
    assert_select "a", { text: /Next/ }
    assert_select "a[href=?]", users_path(per_page: 5, page: 1, keep_me: { pagination: "should-kep-this" }), text: /Previous/
  end

  test "does not show pagination when no enough records" do
    sign_in users(:edu)

    get users_url
    assert_select "a", { text: /Previous/, count: 0 }
    assert_select "a", { text: /Next/, count: 0 }
  end
end
