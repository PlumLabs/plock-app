class Ai::SqlSandbox
  class ForbiddenStatement < StandardError; end

  MAX_ROWS = 1_000.freeze

  FORBIDDEN_KEYWORDS = %w[
    INSERT UPDATE DELETE DROP ALTER CREATE TRUNCATE
    ATTACH DETACH PRAGMA REPLACE VACUUM REINDEX
  ].freeze

  FORBIDDEN_PATTERNS = [
    /\bsessions\b/i,
    /\bai_chats\b/i,
    /\bai_messages\b/i,
    /\bai_models\b/i,
    /\bai_tool_calls\b/i,
    /\bpassword_digest\b/i,
    /\bemail_address\b/i,
    /\bemail\b/i
  ].freeze

  def self.run(sql)
    new(sql).run
  end

  def initialize(sql)
    @sql = sql.to_s.strip.chomp(";").strip
  end

  def run
    raise ForbiddenStatement, "empty query" if @sql.blank?

    reject_multi_statement!
    reject_non_select!
    reject_forbidden_keywords!
    reject_forbidden_tables!

    execute(wrap_with_limit(@sql))
  end

  private

  def reject_multi_statement!
    return unless @sql.include?(";")

    raise ForbiddenStatement, "only a single statement is allowed"
  end

  def reject_non_select!
    first_token = @sql.split(/\s+/, 2).first&.upcase
    return if %w[SELECT WITH].include?(first_token)

    raise ForbiddenStatement, "only SELECT or WITH … SELECT queries are allowed"
  end

  def reject_forbidden_keywords!
    FORBIDDEN_KEYWORDS.each do |kw|
      next unless @sql =~ /\b#{kw}\b/i

      raise ForbiddenStatement, "keyword `#{kw}` is not allowed"
    end
  end

  def reject_forbidden_tables!
    FORBIDDEN_PATTERNS.each do |pattern|
      next unless @sql =~ pattern

      raise ForbiddenStatement, "reference to a restricted table or column"
    end
  end

  def wrap_with_limit(sql)
    "SELECT * FROM (#{sql}) AS sandbox_result LIMIT #{MAX_ROWS}"
  end

  def execute(wrapped_sql)
    result = Ai::ReadonlyRecord.connection.exec_query(wrapped_sql)
    result.to_a # Array<Hash> with string keys, JSON-serializable
  end
end
