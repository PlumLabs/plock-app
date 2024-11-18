class Client < ApplicationRecord
  validates :name, presence: true

  scope :active, -> { where(disabled_at: nil) }

  def disable!
    update!(disabled_at: Time.zone.now)
  end
end
