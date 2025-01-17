class TimeEntry < ApplicationRecord
  include TimeUtil

  belongs_to :user
  belongs_to :project, optional: true

  validates :date, :duration_minutes, :description, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validate :ensure_user_is_a_project_member

  normalizes :duration, with: -> { _1.gsub(/[^0-9:]/, "") }

  def duration
    minutes_to_hours(duration_minutes, "%02d:%02d")
  end

  def duration=(duration)
    hours, minutes = duration.split(":").map(&:to_i)
    self.duration_minutes = hours * 60 + minutes
  end

  def duration_mobile
    hours = duration_minutes / 60
    minutes = duration_minutes % 60
    Time.zone.local(2000, 1, 1, hours, minutes, 0)
  end

  def duration_mobile=(time)
    time_duration = Time.new(*time.values)
    self.duration_minutes = time_duration.hour * 60 + time_duration.min
  end

  private

    def ensure_user_is_a_project_member
      return if project.nil? || project.users.include?(user)

      errors.add(:user, "must be a member of the project")
    end
end
