class AddReferencesToAiChatsAiToolCallsAndAiMessages < ActiveRecord::Migration[8.1]
  def change
    add_reference :ai_chats, :ai_model, foreign_key: true
    add_reference :ai_chats, :user, null: false, foreign_key: true
    add_reference :ai_tool_calls, :ai_message, null: false, foreign_key: true
    add_reference :ai_messages, :ai_chat, null: false, foreign_key: true
    add_reference :ai_messages, :ai_model, foreign_key: true
    add_reference :ai_messages, :ai_tool_call, foreign_key: true
  end
end
