class Ai::Message < ApplicationRecord
  acts_as_message chat: :ai_chat, chat_class: "Ai::Chat", tool_calls: :ai_tool_calls, tool_call_class: "Ai::ToolCall", tool_calls_foreign_key: :ai_message_id, model: :ai_model, model_class: "Ai::Model"

  scope :for_display, -> { includes(:ai_model, :ai_tool_calls, :parent_tool_call) }

  broadcasts_to ->(ai_message) { "ai_chat_#{ai_message.ai_chat_id}" }, inserts_by: :append

  def broadcast_append_chunk(content)
    broadcast_append_to "ai_chat_#{ai_chat_id}",
      target: "ai_message_#{id}_content",
      content: ERB::Util.html_escape(content.to_s)
  end
end
