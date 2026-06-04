require "test_helper"

class Ai::ChatsControllerTest < ActionDispatch::IntegrationTest
  test "user can access their own chat" do
    sign_in users(:edu)

    chat = Ai::Chat.create!(user: users(:edu))
    get ai_chat_url(chat)
    assert_response :success
  end

  test "user cannot access other users' chats" do
    other_user = users(:franco)
    other_user.update!(role: :administrator)

    sign_in users(:edu)

    chat = Ai::Chat.create!(user: other_user)
    get ai_chat_url(chat)
    assert_response :forbidden
  end

  test "administrator users can create a chat" do
    sign_in users(:edu)

    assert_difference "Ai::Chat.count", 1 do
      post ai_chats_url, params: { ai_chat: { prompt: "How many hours last week?" } }
    end
  end

  test "creating a chat enqueues a ChatResponseJob" do
    sign_in users(:edu)

    assert_enqueued_with(job: Ai::ChatResponseJob) do
      post ai_chats_url, params: { ai_chat: { prompt: "How many hours last week?" } }
    end
  end

  test "non-administrator users cannot create a chat" do
    sign_in users(:franco)

    assert_no_difference "Ai::Chat.count" do
      post ai_chats_url, params: { ai_chat: { prompt: "How many hours last week?" } }
    end
  end

  test "non-administrator users cannot access the new chat form" do
    sign_in users(:franco)

    get new_ai_chat_url
    assert_response :forbidden
  end

  test "non-administrator users cannot destroy a chat" do
    sign_in users(:franco)

    chat = Ai::Chat.create!(user: users(:edu))
    assert_no_difference "Ai::Chat.count" do
      delete ai_chat_url(chat)
    end
  end
end
