require "test_helper"

class NavigationHelperTest < ActionView::TestCase
  test "nav_link_to includes active classes when on current page" do
    def current_page?(path)
      true
    end

    result = nav_link_to("Link Text", "/current_page", class: "additional-class")
    assert_includes result, "bg-secondary-hover text-primary-light"
  end

  test "nav_link_to includes default classes when not on current page" do
    def current_page?(path)
      false
    end

    result = nav_link_to("Link Text", "/another_page", class: "additional-class")
    assert_includes result, "text-fg-default hover:text-primary-light hover:bg-secondary-hover"
  end

  test "nav_link_to includes additional classes" do
    def current_page?(path)
      false
    end

    result = nav_link_to("Link Text", "/current_page", class: "additional-class")
    assert_includes result, "additional-class"
  end

  test "nav_link_to renders block content" do
    def current_page?(path)
      true
    end

    result = nav_link_to("Link Text", "/current_page", class: "additional-class") do
      "Block Content"
    end
    assert_includes result, "Block Content"
  end
end
