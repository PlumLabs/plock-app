require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "validates presence of name" do
    assert_not clients(:plum).update(name: nil)
  end
end
