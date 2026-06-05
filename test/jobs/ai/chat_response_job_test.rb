require "test_helper"
require "ostruct"
require "turbo/broadcastable/test_helper"

class Ai::ChatResponseJobTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  test "uses the AnalyticsAssistantAgent" do
    agent = Minitest::Mock.new
    agent.expect :ask, nil, [ "how many hours last week?" ]

    chat = Ai::Chat.create!(title: nil, user: users(:edu))

    AnalyticsAssistantAgent.stub(:new, agent) do
      Ai::ChatResponseJob.new.perform(chat.id, "how many hours last week?")
    end

    assert agent.verify
  end

  test "streams a terminal error to the ai_errors target" do
    Ai::Chat.create!(title: nil, user: users(:edu), id: 42)
    agent = Minitest::Mock.new

    def agent.ask(_content, &_block)
      raise RubyLLM::ConfigurationError, "openai_api_key is missing"
    end

    turbo_streams = capture_turbo_stream_broadcasts "ai_chat_42" do
      AnalyticsAssistantAgent.stub(:new, agent) do
        Ai::ChatResponseJob.new.perform(42, "how many hours last week?")
      end
    end

    assert_equal 1, turbo_streams.size
    stream = turbo_streams.first
    assert_equal "update", stream["action"]
    assert_equal "ai_errors", stream["target"]
    assert_includes stream.to_s, "openai_api_key is missing"
  end

  test "streams a transient error to the ai_transient_errors target" do
    Ai::Chat.create!(title: nil, user: users(:edu), id: 7)
    agent = Minitest::Mock.new

    def agent.ask(_content, &_block)
      raise RubyLLM::RateLimitError, "rate limit exceeded"
    end

    turbo_streams = capture_turbo_stream_broadcasts "ai_chat_7" do
      AnalyticsAssistantAgent.stub(:new, agent) do
        Ai::ChatResponseJob.new.perform(7, "how many hours last week?")
      end
    end

    assert_equal 1, turbo_streams.size
    stream = turbo_streams.first
    assert_equal "update", stream["action"]
    assert_equal "ai_transient_errors", stream["target"]
    assert_includes stream.to_s, "rate limit exceeded"
  end

  test "broadcasts chunks from the chat response" do
    chat = Minitest::Mock.new
    agent = Minitest::Mock.new

    # simulate LLM response
    def agent.ask(content, &block)
      block.call(OpenStruct.new(content: "chunk 1"))
      block.call(OpenStruct.new(content: "chunk 2"))
    end

    ai_message = Minitest::Mock.new
    ai_message.expect(:broadcast_append_chunk, nil, [ "chunk 1" ])
    ai_message.expect(:broadcast_append_chunk, nil, [ "chunk 2" ])
    chat.expect(:ai_messages, [ ai_message ])
    chat.expect(:ai_messages, [ ai_message ])

    AnalyticsAssistantAgent.stub(:new, agent) do
      Ai::Chat.stub(:find, ->(id) { assert_equal 42, id; chat }) do
        Ai::ChatResponseJob.new.perform(42, "how many hours last week?")
      end
    end

    assert chat.verify
    assert ai_message.verify
  end
end
