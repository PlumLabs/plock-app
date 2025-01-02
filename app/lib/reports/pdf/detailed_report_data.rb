class Reports::Pdf::DetailedReportData
  delegate_missing_to :filter

  attr_reader :filter

  def initialize(filter)
    @filter = filter
  end

  def grouped_by_project_results
    filter.results.group_by(&:project_id).map do |_project_id, group|
      project = group.first.project
      total_group_duration = group.sum(&:duration_minutes)

      {
        project_name: project&.name,
        group_duration: minutes_to_hours(total_group_duration),
        results: group
      }
    end
  end

  def total_hours
    minutes_to_hours(filter.total_minutes)
  end

  private

    def minutes_to_hours(minutes)
      hours = minutes / 60
      minutes = minutes % 60
      "#{hours}h #{minutes}m"
    end
end
