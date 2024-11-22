class TimeEntry < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true

  validates :date, :hours, :description, presence: true
  validates :hours, numericality: { greater_than: 0 }
end
