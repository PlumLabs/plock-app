require "test_helper"

class AnalyticsAssistantAgentTest < ActiveSupport::TestCase
  test "it has the expected tools" do
    expected_tools = [ Ai::InspectSchemaTool, Ai::RunSqlTool, Ai::CurrentDateTool ]
    assert_equal expected_tools, AnalyticsAssistantAgent.tools
  end

  test "it's connected to Ai::Chat instance" do
    chat = Ai::Chat.create!(title: nil, user: users(:edu))
    agent = AnalyticsAssistantAgent.new(chat: chat)

    assert_equal chat.id, agent.chat.id
  end

  test "it exposes the transient errors" do
    assert_not_empty AnalyticsAssistantAgent::TRANSIENT_ERRORS
  end

  test "it exposes the terminal errors" do
    assert_not_empty AnalyticsAssistantAgent::TERMINAL_ERRORS
  end

  test "it inherits from RubyLLM::Agent" do
    assert AnalyticsAssistantAgent < RubyLLM::Agent
  end

  test "#ask delegates to chat" do
    chat  = Ai::Chat.create!(title: nil, user: users(:edu))
    agent = AnalyticsAssistantAgent.new(chat: chat)

    called = false
    chat.stub(:ask, ->(*) { called = true }) do
      agent.ask("What is the current date?")
    end

    assert called, "expected agent#ask to delegate to chat#ask"
  end
end
