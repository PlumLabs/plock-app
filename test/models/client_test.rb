require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "validates presence of name" do
    assert_not clients(:plum).update(name: nil)
  end

  test "#disable! sets disabled_at" do
    client = clients(:plum)
    assert_nil client.disabled_at
    client.disable!
    assert_not_nil client.disabled_at
  end

  test ".active returns only active clients" do
    assert_equal 1, Client.active.count

    clients(:plum).disable!

    assert_equal 0, Client.active.count
  end
end
