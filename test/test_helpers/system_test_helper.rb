module SystemTestHelper
  def sign_in(email_address, password = "password")
    visit new_session_url

    fill_in "email_address", with: email_address
    fill_in "password", with: password

    click_on "Sign in"
    assert_text "Dashboard#show"
  end
end
