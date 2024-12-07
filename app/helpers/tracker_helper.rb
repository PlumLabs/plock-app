module TrackerHelper
  def minutes_to_hours(minutes)
    hours = minutes / 60
    minutes = minutes % 60
    "#{hours}h #{minutes}m"
  end
end
