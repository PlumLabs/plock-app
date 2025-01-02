module TimeUtil
  def minutes_to_hours(minutes)
    hours = minutes / 60
    min = minutes % 60
    "#{hours}h #{min}m"
  end
end
