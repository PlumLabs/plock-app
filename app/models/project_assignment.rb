class ProjectAssignment < ApplicationRecord
  enum :role, { member: "member", manager: "manager" }

  validates :user_id, uniqueness: { scope: :project_id, message: "is already assigned to this project" }

  belongs_to :user
  belongs_to :project, touch: true

  delegate :name, :email_address, to: :user, prefix: true
end
