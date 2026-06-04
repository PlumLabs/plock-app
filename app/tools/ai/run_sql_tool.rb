class Ai::RunSqlTool < RubyLLM::Tool
  description <<~DESC
    Execute a read-only SELECT query against the Plock database (SQLite).
    Returns the rows as JSON, or an error string if the query fails.

    DATA RULES — apply on every query:

    - Soft delete: exclude rows where `disabled_at IS NOT NULL` from
      `users`, `clients`, and `projects`. (`time_entries` has no `disabled_at`.)
    - Time math: durations are in `time_entries.duration_minutes`.
      Hours = minutes / 60.0. Do NOT round in SQL — round in the final
      Markdown answer to 2 decimals.
    - Joins: a user is associated with a project via `project_assignments`,
      not directly. Time entries link a user to a project through
      `time_entries.user_id` and `time_entries.project_id` (which can be NULL
      for untracked time).
    - Ranking ties: for "top N" questions, use DENSE_RANK() so users tied
      at rank N are all returned.
    - Result cap: include `LIMIT 100` in your query. If a question would
      naturally return more, aggregate or summarize.
    - Allowed tables: `users`, `clients`, `projects`, `project_assignments`,
      `time_entries`. Do NOT query `sessions`, `ai_chats`, `ai_messages`.

    EXAMPLES

    Top users by hours last week:
      SELECT u.first_name, u.last_name,
             ROUND(SUM(te.duration_minutes) / 60.0, 2) AS hours
      FROM time_entries te
      JOIN users u ON u.id = te.user_id
      WHERE te.date BETWEEN '2026-04-27' AND '2026-05-03'
        AND u.disabled_at IS NULL
      GROUP BY u.id
      ORDER BY hours DESC
      LIMIT 100;

    Hours per client this month:
      SELECT c.name AS client,
             ROUND(SUM(te.duration_minutes) / 60.0, 2) AS hours
      FROM time_entries te
      JOIN projects p ON p.id = te.project_id
      JOIN clients  c ON c.id = p.client_id
      WHERE te.date BETWEEN '2026-05-01' AND '2026-05-31'
        AND p.disabled_at IS NULL
        AND c.disabled_at IS NULL
      GROUP BY c.id
      ORDER BY hours DESC
      LIMIT 100;

    ERROR RECOVERY

    If the query errors (syntax, unknown column, etc.), the error message
    is returned to you. Read it, fix the query, and call again. Try at
    most 2 retries before giving up gracefully.
  DESC

  param :query,
        type: :string,
        desc: "A single SELECT statement. Must include LIMIT. " \
              "Read-only: write statements (INSERT/UPDATE/DELETE/DROP) " \
              "are rejected by the database itself."

  def execute(query:)
    rows = Ai::SqlSandbox.run(query)
    { rows: rows, count: rows.size }.to_json
  rescue ActiveRecord::StatementInvalid, Ai::SqlSandbox::ForbiddenStatement => e
    "SQL error: #{e.message}"
  end
end
