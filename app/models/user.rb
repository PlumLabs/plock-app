class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, :last_name, :email_address, presence: true

  def current?
    self == Current.user
  end

  def name
    [ first_name, last_name ].map(&:capitalize).join(" ")
  end
end
