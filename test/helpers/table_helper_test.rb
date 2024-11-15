require "test_helper"

class TableHelperTest < ActionView::TestCase
  test "filter_link_to returns a link with path and query" do
    result = filter_link_to("Plum", :clients_path, { name_eq: "Plum" })
    assert_includes result, "href=\"/clients?q%5Bname_eq%5D=Plum\""
  end

  test "filter_link_to includes active classes when params includes the query" do
    params[:q] = { name_eq: "Plum" }

    result = filter_link_to("Plum", :clients_path, { name_eq: "Plum" })
    assert_includes result, "text-indigo-600"
  end

  test "filter_link_to includes additional classes" do
    result = filter_link_to("Plum", :clients_path, { name_eq: "Plum" }, class: "additional-class")
    assert_includes result, "additional-class"
  end

  test "filter_link_to includes data attributes" do
    result = filter_link_to("Plum", :clients_path, { name_eq: "Plum" }, data: { confirm: "Are you sure?" })
    assert_includes result, "data-confirm=\"Are you sure?\""
  end
end
