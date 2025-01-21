class Tracker::TimeEntries::DuplicatesController < ApplicationController
  before_action :set_time_entry
  before_action :ensure_user, unless: :can_administrate_or_manage?

  def create
    new_time_entry = @time_entry.dup
    new_time_entry.description = "(Copy) " + @time_entry.description

    respond_to do |format|
      if new_time_entry.save
        format.html { redirect_back fallback_location: tracker_path, notice: "created" }
      else
        format.html { redirect_back fallback_location: tracker_path, notice: "not_created" }
      end
    end
  end

  private
    def set_time_entry
      @time_entry = TimeEntry.find(params.expect(:time_entry_id))
    end

    def ensure_user
      head :forbidden unless @time_entry.user.current?
    end

    def can_administrate_or_manage?
      return true if Current.user.can_administrate?

      Current.user.can_manage_project?(@time_entry.project_id)
    end
end
