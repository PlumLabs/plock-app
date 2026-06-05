class Ai::Model < ApplicationRecord
  acts_as_model chats: :ai_chats, chat_class: "Ai::Chat", chats_foreign_key: :ai_model_id
end
