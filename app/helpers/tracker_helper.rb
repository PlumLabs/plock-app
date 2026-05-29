module TrackerHelper
  def minutes_to_hours(minutes)
    hours = minutes / 60
    minutes = minutes % 60
    "#{hours}h #{minutes}m"
  end

  def human_date_format(date)
    if date == Date.current
      "Today"
    elsif date == Date.yesterday
      "Yesterday"
    else
      date.to_fs(:long)
    end
  end
end
