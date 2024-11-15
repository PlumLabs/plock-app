require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "Administrator addding a new user" do
    sign_in users(:edu).email_address

    visit users_url
    click_on "Add user"

    fill_in "First name", with: "Anakin"
    fill_in "Last name", with: "Skywalker"
    fill_in "Email address", with: "askywalker@plum.com.ar"
    fill_in "Password", with: "123456"
    select "Member", from: "Role"

    click_on "Create User"

    assert_text "Successfully created!"
    assert_text "Anakin Skywalker"
  end

  test "Administrator destroying an user" do
    sign_in users(:edu).email_address

    visit users_url

    assert_text "Franco Colapinto"

    within "li[data-test-id='#{users(:franco).id}']" do
      click_on "Edit"
    end

    page.accept_confirm do
      click_on "Yes, Delete user account"
    end

    assert_text "Successfully deleted"
    assert_no_text "Franco Colapinto"
  end
end
