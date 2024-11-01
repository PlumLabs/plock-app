module SessionTestHelper
  def sign_in(user)
    post session_url, params: { email_address: user.email_address, password: "password" }
    assert cookies[:session_id].present?
  end

  def sign_out
    delete session_url
    assert_not cookies[:session_id].present?
  end
end
