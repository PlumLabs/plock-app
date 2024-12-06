class Project < ApplicationRecord
  validates :name, presence: true

  belongs_to :client, optional: true
  has_many :project_assignments, dependent: :destroy
  has_many :users, through: :project_assignments
  has_many :time_entries

  scope :active, -> { where(disabled_at: nil) }

  def disable!
    update!(disabled_at: Time.zone.now)
  end
end
