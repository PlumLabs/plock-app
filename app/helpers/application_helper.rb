module ApplicationHelper
  def user_initials(user)
    [ user.first_name.first, user.last_name.first ].join
  end
end
