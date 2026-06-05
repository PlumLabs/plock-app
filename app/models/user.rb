class User < ApplicationRecord
  include Role

  has_secure_password

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, :last_name, :email_address, presence: true
  validates :email_address, uniqueness: true

  has_many :sessions, dependent: :destroy
  has_many :project_assignments, dependent: :destroy
  has_many :projects, through: :project_assignments
  has_many :time_entries, dependent: :destroy
  has_many :ai_chats, class_name: "Ai::Chat", dependent: :destroy

  scope :active, -> { where(disabled_at: nil) }
  scope :archive, -> { where.not(disabled_at: nil) }

  def active?
    disabled_at.nil?
  end

  def deactivate
    transaction do
      sessions.delete_all
      update!(disabled_at: Time.current, password: SecureRandom.hex(16))
    end
  end

  def current?
    self == Current.user
  end

  def name
    [ first_name, last_name ].map(&:capitalize).join(" ")
  end
end
