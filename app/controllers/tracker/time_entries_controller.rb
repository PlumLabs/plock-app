class Tracker::TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: %i[ update destroy ]
  before_action :ensure_user, unless: -> { Current.user.can_administrate? }, only: %i[ create update destroy ]

  def create
    @time_entry = TimeEntry.new(time_entry_params)

    respond_to do |format|
      if @time_entry.save
        format.html { redirect_to tracker_path, notice: "created" }
      else
        format.html { render tracker_path, notice: "not_created" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@time_entry, partial: "form", locals: { time_entry: @time_entry })
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @time_entry.update(time_entry_params)
        format.html { redirect_to tracker_path, notice: "updated" }
      else
        format.html { render tracker_path, notice: "not_updated" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@time_entry, partial: "form", locals: { time_entry: @time_entry }, method: :morph)
        end
      end
    end
  end

  def destroy
    @time_entry.destroy!

    respond_to do |format|
      format.html { redirect_to tracker_path, status: :see_other, notice: "destroyed" }
    end
  end

  private
    def set_time_entry
      @time_entry = TimeEntry.find(params.expect(:id))
    end

    def ensure_user
      user_id = @time_entry&.user_id || time_entry_params[:user_id].to_i
      head :forbidden unless user_id == Current.user.id
    end

    def time_entry_params
      if params[:button] == "mobile"
        params.expect(time_entry: [ :user_id, :project_id, :date, :duration_mobile, :description ])
      else
        params.expect(time_entry: [ :user_id, :project_id, :date, :duration, :description ])
      end
    end
end
