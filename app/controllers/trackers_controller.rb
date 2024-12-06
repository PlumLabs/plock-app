class TrackersController < ApplicationController
  def show
    @time_entry = Current.user.time_entries.new(date: Date.current)
    @time_entries_grouped_by_week = Current.user.time_entries.order(date: :desc).group_by do |entry|
      entry.date.beginning_of_week
    end
  end
end
