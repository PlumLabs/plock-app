class Ai::CurrentDateTool < RubyLLM::Tool
  description <<~DESC
    Returns today's date in the configured timezone plus useful relative-date anchors.

    Call this whenever the user's question contains a relative date phrase:
    "today", "yesterday", "this week", "last week", "this month",
    "last month", "this quarter", etc. The model does not know what
    today is — never assume.

    Returns JSON with:
      {
        "today":             "YYYY-MM-DD",
        "yesterday":         "YYYY-MM-DD",
        "this_week_start":   "YYYY-MM-DD",   // Monday of current week
        "this_week_end":     "YYYY-MM-DD",   // Sunday of current week
        "last_week_start":   "YYYY-MM-DD",   // previous Monday
        "last_week_end":     "YYYY-MM-DD",   // previous Sunday
        "this_month_start":  "YYYY-MM-DD",   // 1st of current month
        "this_month_end":    "YYYY-MM-DD",   // today (running month)
        "last_month_start":  "YYYY-MM-DD",
        "last_month_end":    "YYYY-MM-DD",
        "timezone":          "Zone name, e.g. America/Argentina/Buenos_Aires"
      }

    Use these dates literally in SQL — they're already resolved against
    the correct timezone.
  DESC

  def execute
    zone_name = Time.zone&.name || Rails.application.config.time_zone || "UTC"

    Time.use_zone(zone_name) do
      today = Date.current
      {
        today:            today.iso8601,
        yesterday:        (today - 1).iso8601,
        this_week_start:  today.beginning_of_week(:monday).iso8601,
        this_week_end:    today.end_of_week(:monday).iso8601,
        last_week_start:  (today - 7).beginning_of_week(:monday).iso8601,
        last_week_end:    (today - 7).end_of_week(:monday).iso8601,
        this_month_start: today.beginning_of_month.iso8601,
        this_month_end:   today.iso8601,
        last_month_start: (today << 1).beginning_of_month.iso8601,
        last_month_end:   (today << 1).end_of_month.iso8601,
        timezone:         zone_name
      }.to_json
    end
  end
end
