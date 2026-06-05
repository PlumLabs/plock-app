class Ai::InspectSchemaTool < RubyLLM::Tool
  ALLOWED_TABLES = %w[users clients projects project_assignments time_entries].freeze
  HIDDEN_COLUMNS = %w[password_digest email_address email].freeze

  description <<~DESC
    Returns the columns and types for one allowlisted table. Call this
    when you are not sure of a column name, type, or which table holds
    a piece of data.

    Allowed tables: #{ALLOWED_TABLES.join(", ")}.

    Sensitive columns (`password_digest`, `email_address`) are filtered
    from the response — they are not available to query.

    You usually do NOT need to call this for common columns
    (`time_entries.duration_minutes`, `time_entries.date`, `users.first_name`,
    etc.). Use it when in doubt rather than guessing.
  DESC

  param :table,
        type: :string,
        desc: "Table name. Must be one of the allowed tables above."

  def execute(table:)
    return "table not available" unless ALLOWED_TABLES.include?(table)

    cols = Ai::ReadonlyRecord.connection.columns(table)
                             .reject { |c| HIDDEN_COLUMNS.include?(c.name) }
                             .map    { |c| { name: c.name, type: c.type.to_s } }
    { table: table, columns: cols }.to_json
  end
end
