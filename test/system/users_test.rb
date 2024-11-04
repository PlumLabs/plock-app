require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "add new user" do
    sign_in users(:edu).email_address

    visit users_url
    click_on "Add user"

    fill_in "First name", with: "Anakin"
    fill_in "Last name", with: "Skywalker"
    fill_in "Email address", with: "askywalker@plum.com.ar"
    fill_in "Password", with: "123456"
    select "Member", from: "Role"

    click_on "Create"

    assert_text "Successfully created!"
    assert_text "Anakin Skywalker"
  end

  test "destroy user" do
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

  test "Deactivate user" do
    sign_in users(:edu).email_address

    visit users_url

    assert_text "Franco Colapinto"

    within "li[data-test-id='#{users(:franco).id}']" do
      click_on "Edit"
    end

    assert users(:franco).active?

    page.accept_confirm do
      click_on "Yes, Deactivate the account"
    end

    assert_not users(:franco).reload.active?
    assert_text "Deactivate at:"
    assert_text "Reactivate User Account"
  end

  test "Reactivate user" do
    sign_in users(:edu).email_address

    users(:franco).deactivate
    assert_not users(:franco).reload.active?

    visit users_url

    assert_text "Franco Colapinto"

    within "li[data-test-id='#{users(:franco).id}']" do
      click_on "Edit"
    end

    page.accept_confirm do
      click_on "Reactivate the account"
    end

    assert users(:franco).reload.active?
  end
end
