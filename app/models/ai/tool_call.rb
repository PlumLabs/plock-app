class Ai::ToolCall < ApplicationRecord
  acts_as_tool_call message: :ai_message, message_class: "Ai::Message", result_foreign_key: :ai_tool_call_id
end
