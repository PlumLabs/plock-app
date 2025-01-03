module TimeUtil
  def minutes_to_hours(minutes, format = "%dh %dm")
    hours = minutes / 60
    min = minutes % 60
    format(format, hours, min)
  end
end
