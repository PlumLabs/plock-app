require "test_helper"
require "turbo/broadcastable/test_helper"

class Ai::MessageTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  test "should belong to a chat" do
    chat = Ai::Chat.create!(user: users(:edu))

    message = Ai::Message.create!(ai_chat: chat, content: "Hello there!", role: "user")
    assert_equal chat, message.ai_chat
  end

  test "enqueues a turbo stream broadcast" do
    chat = Ai::Chat.create!(user: users(:edu))

    assert_turbo_stream_broadcasts "ai_chat_#{chat.id}", count: 1 do
      perform_enqueued_jobs do
        chat.ai_messages.create!(role: "user", content: "Hello there!")
      end
    end
  end

  test "#broadcast_append_chunk html-escapes the content" do
    message = Ai::Message.create!(ai_chat: Ai::Chat.create!(user: users(:edu)), content: "<b>hi</b>", role: "user")

    turbo_streams = capture_turbo_stream_broadcasts "ai_chat_#{message.ai_chat_id}" do
      message.broadcast_append_chunk("<b>hi</b>")
    end

    assert_includes turbo_streams.first.inner_html.strip, ERB::Util.html_escape("<b>hi</b>")
  end

  test ".for_display eager-loads ai_model, ai_tool_calls and parent_tool_call" do
    chat = Ai::Chat.create!(user: users(:edu))
    assistant = chat.ai_messages.create!(role: "assistant", content: "calling tool")
    assistant.ai_tool_calls.create!(tool_call_id: "call_1", name: "search", arguments: {})

    messages = Ai::Message.for_display.where(ai_chat: chat).to_a

    assert messages.all? { |m| m.association(:ai_model).loaded? }
    assert messages.all? { |m| m.association(:ai_tool_calls).loaded? }
    assert messages.all? { |m| m.association(:parent_tool_call).loaded? }
  end

  test "#broadcast_append_chunk targets the message content element on the chat stream" do
    message = Ai::Message.create!(ai_chat: Ai::Chat.create!(user: users(:edu)), content: "x", role: "user")

    turbo_streams = capture_turbo_stream_broadcasts "ai_chat_#{message.ai_chat_id}" do
      message.broadcast_append_chunk("hi")
    end

    stream = turbo_streams.first
    assert_equal "append", stream["action"]
    assert_equal "ai_message_#{message.id}_content", stream["target"]
  end
end
