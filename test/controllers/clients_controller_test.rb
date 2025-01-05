require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:plum)
    sign_in users(:edu)
  end

  test "administrator should get index" do
    get clients_url
    assert_response :success
  end

  test "administrator should get new" do
    get new_client_url
    assert_response :success
  end

  test "administrator should create client" do
    assert_difference("Client.count") do
      post clients_url, params: { client: { email: @client.email, name: @client.name, note: @client.note } }
    end

    assert_redirected_to clients_url
  end

  test "administrator should get edit" do
    get edit_client_url(@client)
    assert_response :success
  end

  test "administrator should update client" do
    patch client_url(@client), params: { client: { email: @client.email, name: @client.name, note: @client.note } }
    assert_redirected_to clients_url
  end

  test "administrator should destroy client" do
    assert_difference("Client.active.count", -1) do
      delete client_url(@client)
    end

    assert_redirected_to clients_url
  end

  test "memeber should not get index" do
    users(:edu).update!(role: "member")

    get clients_url
    assert_response :forbidden
  end

  test "memeber should not get new" do
    users(:edu).update!(role: "member")

    get new_client_url
    assert_response :forbidden
  end

  test "memeber should not create client" do
    users(:edu).update!(role: "member")

    assert_no_difference("Client.count") do
      post clients_url, params: { client: {} }
    end

    assert_response :forbidden
  end

  test "memeber should not get edit" do
    users(:edu).update!(role: "member")

    get edit_client_url(@client)
    assert_response :forbidden
  end

  test "memeber should not update client" do
    users(:edu).update!(role: "member")

    patch client_url(@client), params: { client: {} }
    assert_response :forbidden
  end

  test "memeber should not destroy client" do
    users(:edu).update!(role: "member")

    assert_no_difference("Client.count") do
      delete client_url(@client)
    end

    assert_response :forbidden
  end

  test "search by client" do
    Client.create!(name: "Google")

    get clients_url

    assert_match /Google/, @response.body
    assert_match /Plum/, @response.body

    get clients_url, params: { q: { name_or_email_cont: "google" } }

    assert_response :success
    assert_no_match /Plum/, @response.body
    assert_match /Google/, @response.body
  end

  test "filter by status" do
    Client.create!(name: "Google", disabled_at: Time.zone.now)
    Client.create!(name: "Apple", disabled_at: Time.zone.now)

    get clients_url, params: { q: { status_eq: "archive" } }

    assert_match /Google/, @response.body
    assert_match /Apple/, @response.body

    get clients_url, params: { q: { status_eq: "archive", name_or_email_cont: "google" } }

    assert_response :success
    assert_no_match /Apple/, @response.body
    assert_match /Google/, @response.body
  end

  test "clients are paginated" do
    10.times do
      name = Faker::Company.unique.name
      Client.create!(name: name, email: Faker::Internet.unique.email(name: name, domain: "plum.com.ar"), note: "test")
    end

    get clients_url, params: { per_page: 5 }
    assert_select "a", { text: /Next/ }
    assert_select "a", { text: /Previous/, count: 0 }

    # Navigate to the second page to test the presence of the "Previous" link
    get clients_url, params: { page: 2, per_page: 5 }
    assert_select "a", { text: /Next/ }
    assert_select "a", { text: /Previous/ }
  end

  test "does not show pagination when no enough records" do
    get clients_url
    assert_select "a", { text: /Previous/, count: 0 }
    assert_select "a", { text: /Next/, count: 0 }
  end
end
