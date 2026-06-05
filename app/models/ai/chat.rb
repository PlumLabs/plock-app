class Ai::Chat < ApplicationRecord
  belongs_to :user
  acts_as_chat messages: :ai_messages, message_class: "Ai::Message", messages_foreign_key: :ai_chat_id, model: :ai_model, model_class: "Ai::Model"

  validates :title, length: { maximum: 255 }, allow_nil: true

  def title
    super || "Chat ##{id} #{created_at&.strftime("%Y-%m-%d %H:%M")}"
  end
end
