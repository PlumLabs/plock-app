module Ai::ChatsHelper
  SUGGESTED_PROMPTS = [
    "Who tracked the most hours last week?",
    "How many hours on Client X this month?",
    "Top 5 projects by hours this month",
    "Who logged 0 hours yesterday?"
  ].freeze

  def suggested_prompts
    SUGGESTED_PROMPTS
  end
end
