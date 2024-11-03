require "test_helper"

class NavigationHelperTest < ActionView::TestCase
  test "nav_link_to includes active classes when on current page" do
    # Simulate the current page
    def current_page?(path)
      true
    end

    result = nav_link_to("Link Text", "/current_page", class: "additional-class")
    assert_includes result, "bg-gray-50 text-indigo-600"
  end

  test "nav_link_to includes default classes when not on current page" do
    # Simulate not being on the current page
    def current_page?(path)
      false
    end

    result = nav_link_to("Link Text", "/another_page", class: "additional-class")
    assert_includes result, "text-gray-700 hover:text-indigo-600 hover:bg-gray-50"
  end

  test "nav_link_to includes additional classes" do
    # Simulate not being on the current page
    def current_page?(path)
      false
    end

    result = nav_link_to("Link Text", "/current_page", class: "additional-class")
    assert_includes result, "additional-class"
  end

  test "nav_link_to renders block content" do
    # Simulate the current page
    def current_page?(path)
      true
    end

    result = nav_link_to("Link Text", "/current_page", class: "additional-class") do
      "Block Content"
    end
    assert_includes result, "Block Content"
  end
end
