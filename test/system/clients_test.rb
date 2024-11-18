require "application_system_test_case"

class ClientsTest < ApplicationSystemTestCase
  test "Administrator addding a new client" do
    sign_in users(:edu).email_address

    visit clients_url
    click_on "Add client"

    fill_in "Name", with: "Google"
    fill_in "Email address", with: "google@plum.com.ar"
    fill_in "Note", with: "This is a note"

    click_on "Create Client"

    assert_text "Successfully created!"
    assert_text "Google"
  end

  test "Administrator edits a client" do
    sign_in users(:edu).email_address

    visit clients_url

    assert_text "Plum"
    assert_no_text "Plum Software"

    within "li[data-test-id='#{clients(:plum).id}']" do
      click_on "Edit"
    end

    fill_in "Name", with: "Plum Software"
    click_on "Update Client"

    assert_text "Successfully updated!"
    assert_text "Plum Software"
  end

  test "Administrator archive a client" do
    sign_in users(:edu).email_address

    visit clients_url

    assert_text "Plum"
    assert clients(:plum).disabled_at.nil?

    within "li[data-test-id='#{clients(:plum).id}']" do
      page.accept_confirm do
        click_link "Archive"
      end
    end

    assert_text "Successfully archived!"
    assert clients(:plum).reload.disabled_at?
  end

  test "Administrator activate a client" do
    sign_in users(:edu).email_address
    clients(:plum).disable!

    visit clients_url

    assert_text "Plum"
    assert clients(:plum).disabled_at?

    within "li[data-test-id='#{clients(:plum).id}']" do
      page.accept_confirm do
        click_on "Activate"
      end
    end

    assert_text "Successfully updated!"
    assert_not clients(:plum).reload.disabled_at?
  end
end
