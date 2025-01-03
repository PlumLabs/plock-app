class Client < ApplicationRecord
  validates :name, presence: true

  has_many :projects, dependent: :destroy

  scope :active, -> { where(disabled_at: nil) }
  scope :archive, -> { where.not(disabled_at: nil) }

  def disable!
    update!(disabled_at: Time.zone.now)
  end
end
