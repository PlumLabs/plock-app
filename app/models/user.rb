class User < ApplicationRecord
  has_secure_password

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { member: "member", administrator: "administrator" }

  validates :first_name, :last_name, :email_address, presence: true
  validates :email_address, uniqueness: true

  has_many :sessions, dependent: :destroy
  has_many :project_assignments, dependent: :destroy
  has_many :projects, through: :project_assignments

  scope :active, -> { where(disabled_at: nil) }

  def can_administrate?
    administrator?
  end

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
