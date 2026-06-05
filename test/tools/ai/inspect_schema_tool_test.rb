require "test_helper"

class Ai::InspectSchemaToolTest < ActiveSupport::TestCase
  test "returns the columns and types for an allowed table" do
    result = JSON.parse(Ai::InspectSchemaTool.new.execute(table: "time_entries"))

    assert_equal "time_entries", result["table"]

    columns = result["columns"]
    assert_kind_of Array, columns
    columns.each do |column|
      assert_kind_of String, column["name"]
      assert_kind_of String, column["type"]
    end

    names = columns.map { |c| c["name"] }
    assert_includes names, "duration_minutes"
    assert_includes names, "date"
  end

  test "filters out hidden / sensitive columns" do
    user_columns = JSON.parse(Ai::InspectSchemaTool.new.execute(table: "users")).fetch("columns")
    user_names = user_columns.map { |c| c["name"] }
    assert_not_includes user_names, "password_digest"
    assert_not_includes user_names, "email_address"

    client_names = JSON.parse(Ai::InspectSchemaTool.new.execute(table: "clients"))
                       .fetch("columns").map { |c| c["name"] }
    assert_not_includes client_names, "email"
  end

  test "rejects tables that are not on the allowlist" do
    %w[sessions ai_messages ai_chats bogus_table].each do |table|
      assert_equal "table not available", Ai::InspectSchemaTool.new.execute(table: table)
    end
  end
end
