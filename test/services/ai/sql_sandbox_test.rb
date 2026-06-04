require "test_helper"

class Ai::SqlSandboxTest < ActiveSupport::TestCase
  test "rejects a blank query" do
    error = assert_raises(Ai::SqlSandbox::ForbiddenStatement) { Ai::SqlSandbox.run("   ") }
    assert_equal "empty query", error.message
  end

  test "rejects multiple statements" do
    error = assert_raises(Ai::SqlSandbox::ForbiddenStatement) do
      Ai::SqlSandbox.run("SELECT name FROM clients; SELECT name FROM projects")
    end
    assert_equal "only a single statement is allowed", error.message
  end

  test "rejects non-SELECT statements" do
    error = assert_raises(Ai::SqlSandbox::ForbiddenStatement) do
      Ai::SqlSandbox.run("UPDATE clients SET name = 'x'")
    end
    assert_equal "only SELECT or WITH … SELECT queries are allowed", error.message
  end

  test "rejects forbidden keywords even inside an otherwise SELECT query" do
    error = assert_raises(Ai::SqlSandbox::ForbiddenStatement) do
      Ai::SqlSandbox.run("SELECT name FROM clients WHERE 1 = (DROP TABLE clients)")
    end
    assert_equal "keyword `DROP` is not allowed", error.message
  end

  test "rejects references to restricted tables" do
    %w[sessions ai_chats ai_messages].each do |table|
      error = assert_raises(Ai::SqlSandbox::ForbiddenStatement) do
        Ai::SqlSandbox.run("SELECT * FROM #{table}")
      end
      assert_equal "reference to a restricted table or column", error.message
    end
  end

  test "rejects references to restricted columns" do
    %w[password_digest email_address].each do |column|
      error = assert_raises(Ai::SqlSandbox::ForbiddenStatement) do
        Ai::SqlSandbox.run("SELECT #{column} FROM users")
      end
      assert_equal "reference to a restricted table or column", error.message
    end
  end

  test "runs a SELECT query and returns an array of hashes with string keys" do
    rows = Ai::SqlSandbox.run("SELECT name FROM clients ORDER BY name")

    assert_kind_of Array, rows
    assert_equal({ "name" => "Plum" }, rows.first)
  end

  test "allows WITH … SELECT queries" do
    sql = "WITH c AS (SELECT name FROM clients) SELECT name FROM c"

    assert_equal [ { "name" => "Plum" } ], Ai::SqlSandbox.run(sql)
  end

  test "tolerates a trailing semicolon" do
    assert_nothing_raised do
      Ai::SqlSandbox.run("SELECT name FROM clients;")
    end
  end

  test "is case-insensitive about the leading keyword" do
    assert_nothing_raised do
      Ai::SqlSandbox.run("select name from clients")
    end
  end

  test "executes the query against the read-only connection" do
    connection = Minitest::Mock.new
    connection.expect(:exec_query, []) { true }

    Ai::ReadonlyRecord.stub(:connection, connection) do
      Ai::SqlSandbox.run("SELECT name FROM clients")
    end

    assert_mock connection
  end

  # Without the limit wrapper, it should return MAX_ROWS + 50. With the wrapper, it should return only MAX_ROWS.
  test "caps the number of returned rows at MAX_ROWS" do
    oversized = <<~SQL.squish
      WITH RECURSIVE seq(n) AS (
        SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < #{Ai::SqlSandbox::MAX_ROWS + 50}
      )
      SELECT n FROM seq
    SQL

    assert_equal Ai::SqlSandbox::MAX_ROWS, Ai::SqlSandbox.run(oversized).length
  end
end
