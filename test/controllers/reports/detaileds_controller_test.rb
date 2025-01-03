require "test_helper"

class Reports::DetailedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:two)

    @member = User.create!(
      first_name: "Alan",
      last_name: "Turing",
      email_address: "aturing@plum.com.ar",
      password: "password",
      role: :member
    )

    @manager = users(:franco)

    @project.project_assignments.create!(user: @member, role: :member)
    @project.project_assignments.create!(user: @manager, role: :manager)
    @project.save!
  end

  test "logged in as an admin I can see reports" do
    sign_in users(:edu)
    get reports_detailed_url
    assert_response :success
  end

  test "logged in as a member who is a project manager I can see reports" do
    sign_in @manager
    get reports_detailed_url
    assert_response :success
  end

  test "logged in as user I can't see reports" do
    sign_in @member
    get reports_detailed_url
    assert_response :forbidden
  end

  test "report allows pdf format" do
    sign_in users(:edu)
    get reports_detailed_url(format: :pdf)
    assert_response :success
  end
end
