class Project < ApplicationRecord
  validates :name, presence: true
  belongs_to :client, optional: true

  scope :active, -> { where(disabled_at: nil) }

  def disable!
    update!(disabled_at: Time.zone.now)
  end
end
