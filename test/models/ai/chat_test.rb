require "test_helper"

class Ai::ChatTest < ActiveSupport::TestCase
  test "persists ai messages through the chat" do
    chat = Ai::Chat.create!(user: users(:edu))
    chat.ai_messages.create!(role: :user, content: "hello")

    assert_equal [ "hello" ], chat.reload.ai_messages.map(&:content)
  end

  test "chat can have empty title" do
    chat = Ai::Chat.create!(title: nil, user: users(:edu))
    assert chat.persisted?
  end

  test "title returns a default value when it's nil" do
    chat = Ai::Chat.create!(title: nil, user: users(:edu))
    assert_equal "Chat ##{chat.id} #{chat.created_at&.strftime("%Y-%m-%d %H:%M")}", chat.title
  end

  test "returns the title when it's present" do
    chat = Ai::Chat.create!(title: "My Chat", user: users(:edu))
    assert_equal "My Chat", chat.title
  end

  test "should not allow title longer than 255 characters" do
    long_title = "a" * 256
    chat = Ai::Chat.new(title: long_title, user: users(:edu))
    assert_not chat.valid?
    assert_includes chat.errors[:title], "is too long (maximum is 255 characters)"
  end

  test "should not allow chat without user" do
    chat = Ai::Chat.new(title: "Test Chat", user: nil)
    assert_not chat.valid?
    assert_includes chat.errors[:user], "must exist"
  end
end
