module Authorization
  private
    def ensure_can_administrate
      head :forbidden unless Current.user.can_administrate?
    end

    def ensure_current_user
      head :forbidden unless @user.current?
    end

    def ensure_can_manage_projects
      head :forbidden unless Current.user.can_manage_projects?
    end
end
