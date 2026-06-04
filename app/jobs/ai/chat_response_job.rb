module Ai
  class ChatResponseJob < ApplicationJob
    def perform(ai_chat_id, content)
      ai_chat = Ai::Chat.find(ai_chat_id)
      agent = AnalyticsAssistantAgent.new(chat: ai_chat)

      agent.ask(content) do |chunk|
        if chunk.content && !chunk.content.empty?
          ai_message = ai_chat.ai_messages.last
          ai_message.broadcast_append_chunk(chunk.content)
        end
      end
    rescue *AnalyticsAssistantAgent::TERMINAL_ERRORS => e
      Rails.logger.error("[ChatResponseJob] #{e.class}: #{e.message}")
      broadcast_error(ai_chat, e)
    rescue *AnalyticsAssistantAgent::TRANSIENT_ERRORS => e
      Rails.logger.warn("[ChatResponseJob] Transient error #{e.class}: #{e.message}")
      broadcast_transient_error(ai_chat, e)
    end

    private
      def broadcast_error(ai_chat, exception)
        Turbo::StreamsChannel.broadcast_update_to(
          "ai_chat_#{ai_chat.id}",
          target: "ai_errors",
          html: "#{exception&.message || 'An error occurred while processing your request.'}"
        )
      end

      def broadcast_transient_error(ai_chat, exception)
        Turbo::StreamsChannel.broadcast_update_to(
          "ai_chat_#{ai_chat.id}",
          target: "ai_transient_errors",
          html: "A transient error occurred: #{exception&.message || 'Please try again.'}"
        )
      end
  end
end
