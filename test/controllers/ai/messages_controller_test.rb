require "test_helper"

class Ai::MessagesControllerTest < ActionDispatch::IntegrationTest
  test "administrator users can create a message" do
    sign_in users(:edu)

    chat = Ai::Chat.create!(user: users(:edu))

    assert_enqueued_with(job: Ai::ChatResponseJob) do
      post ai_chat_messages_url(chat), params: { ai_message: { content: "How many hours last week?" } }
    end
  end

  test "non-administrator users cannot create a message" do
    sign_in users(:franco)

    chat = Ai::Chat.create!(user: users(:edu))

    assert_no_enqueued_jobs only: Ai::ChatResponseJob do
      post ai_chat_messages_url(chat), params: { ai_message: { content: "How many hours last week?" } }
    end
  end

  test "users cannot create a message for a chat that does not belong to them" do
    sign_in users(:edu)

    chat = Ai::Chat.create!(user: users(:franco))

    assert_no_enqueued_jobs only: Ai::ChatResponseJob do
      post ai_chat_messages_url(chat), params: { ai_message: { content: "How many hours last week?" } }
    end
  end
end
