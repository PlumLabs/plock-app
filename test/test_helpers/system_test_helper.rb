module SystemTestHelper
  def sign_in(email_address, password = "password")
    visit new_session_url

    fill_in "email_address", with: email_address
    fill_in "password", with: password

    click_on "Sign in"

    assert_selector("[data-testid='app']") # Wait for the app to load
  end

  def sign_out(user)
    visit edit_user_profile_url(user)

    click_on "Sign out"

    assert_text "Sign in to your account"
  end
end
