require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  test "Administrator addding a new project" do
    sign_in users(:edu).email_address

    visit projects_url
    click_on "Add project"

    fill_in "Name", with: "HR assistant"

    click_on "Create Project"

    assert_text "HR assistant"
  end

  test "Administrator edits a project" do
    sign_in users(:edu).email_address

    visit projects_url

    assert_text "www site"
    assert_no_text "www New site"

    within "li[data-test-id='#{projects(:one).id}']" do
      click_on "Edit"
    end

    fill_in "Name", with: "www New site"
    click_on "Update Project"

    assert_text "www New site"
  end

  test "Administrator archive a project" do
    sign_in users(:edu).email_address

    visit projects_url

    assert_text "www site"
    assert projects(:one).disabled_at.nil?

    within "li[data-test-id='#{projects(:one).id}']" do
      page.accept_confirm do
        click_link "Archive"
      end
    end

    assert_text "Successfully archived!"
    assert projects(:one).reload.disabled_at?
  end

  test "Administrator activate a project" do
    sign_in users(:edu).email_address
    projects(:one).disable!

    visit projects_url

    assert_text "www site"
    assert projects(:one).disabled_at?

    within "li[data-test-id='#{projects(:one).id}']" do
      page.accept_confirm do
        click_on "Activate"
      end
    end

    assert_text "Successfully updated!"
    assert_not projects(:one).reload.disabled_at?
  end
end
