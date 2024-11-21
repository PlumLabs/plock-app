require "application_system_test_case"

class ProjectAssignmentsTest < ApplicationSystemTestCase
  setup do
    @project = project_assignments(:one_manager).project
  end

  test "Administrator adding a member to a project" do
    sign_in users(:edu).email_address

    visit project_url(@project)

    assert_text "Members"
    assert_no_text "Franco Colapinto"

    click_on "Add member"

    within "li[data-test-id='#{users(:franco).id}']" do
      click_on "Add to project"
    end

    assert_text "Successfully created!"
    assert_text "Franco Colapinto"
  end

  test "Administrator removing a member from the project" do
    sign_in users(:edu).email_address

    visit project_url(@project)

    assert_text "Members"
    assert_text "Eduardo Depetris"

    within "li[data-test-id='#{project_assignments(:one_manager).id}']" do
      page.accept_confirm do
        click_on "Remove"
      end
    end

    assert_text "Successfully destroyed!"
  end

  test "Administrator update the a membership role" do
    sign_in users(:edu).email_address

    visit project_url(@project)

    within "li[data-test-id='#{project_assignments(:one_manager).id}']" do
      assert_text "Manager"
      click_on "Edit"
    end

    assert_text "Update membership"
    select "Member", from: "Role"

    click_on "Update Project assignment"

    within "li[data-test-id='#{project_assignments(:one_manager).id}']" do
      assert_text "Member"
    end
  end
end
