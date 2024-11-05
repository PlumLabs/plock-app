require "application_system_test_case"

class UserProfilesTest < ApplicationSystemTestCase
  test "Administrator deactivating an user" do
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

  test "Administrator reactivating an user" do
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

    assert_text "Deactivate User Account"
    assert users(:franco).reload.active?
  end

  test "Administrator converting a member into administrator" do
    sign_in users(:edu).email_address

    visit users_url

    assert_text "Franco Colapinto"

    within "li[data-test-id='#{users(:franco).id}']" do
      click_on "Edit"
    end

    assert users(:franco).member?

    select "Administrator", from: "Role"

    within "#role_user_#{users(:franco).id}" do
      page.accept_confirm do
        click_on "Save"
      end
    end

    assert_text "Successfully uploaded"

    assert users(:franco).reload.administrator?
  end
end
