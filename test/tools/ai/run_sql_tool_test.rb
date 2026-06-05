require "test_helper"

class Ai::RunSqlToolTest < ActiveSupport::TestCase
  test "uses sql sandbox service" do
    Ai::SqlSandbox.stub(:run, ->(query) { [ "a" ] }) do
      tool = Ai::RunSqlTool.new
      result = tool.execute(query: "anything")
      assert_includes result, [ "a" ].to_json
    end
  end

  test "execute returns an error string when the sandbox raises a known exception" do
    exceptions = [ ActiveRecord::StatementInvalid, Ai::SqlSandbox::ForbiddenStatement ]

    exceptions.each do |exception_class|
      Ai::SqlSandbox.stub(:run, ->(_query) { raise exception_class, "this is the error" }) do
        result = Ai::RunSqlTool.new.execute(query: "SELECT * FROM users")

        assert_kind_of String, result
        assert_equal "SQL error: this is the error", result
      end
    end
  end

  test "returns the result in a JSON format including rows and count" do
    expected = User.all.map { { "first_name" => it.first_name } }

    result = Ai::RunSqlTool.new.execute(query: "SELECT first_name FROM users")

    assert_kind_of String, result
    parsed = JSON.parse(result)
    assert_equal expected, parsed["rows"]
    assert_equal expected.size, parsed["count"]
  end
end
