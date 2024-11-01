require "application_system_test_case"

class SignInsTest < ApplicationSystemTestCase
  test "Signing in" do
    visit new_session_path

    fill_in "Email address", with: users(:edu).email_address
    fill_in "Password", with: "password"
    click_on "Sign in"

    assert_text "Dashboard#show"
  end

  test "Signing out" do
    sign_in users(:edu).email_address

    # sidebar
    click_on "Eduardo Depetris"

    click_on "Sign out"

    assert_text "Sign in to your account"
  end

  test "Forgot password" do
    visit new_session_path

    click_on "Forgot password?"

    assert_text "Contact Application Admin"
  end
end
