class Reports::FileNameGenerator
  def initialize(filter)
    @filter = filter
  end

  def name(format: "pdf")
    filename = sanitize_text("report_#{target}_#{dates}")
    "#{filename}.#{format}"
  end

  private

    attr_reader :filter

    def dates
      [ filter.start_date, filter.end_date ].compact.map { |date| date.strftime("%d-%m-%Y") }.join("--")
    end

    def target
      if client_report?
        client_name
      elsif project_report?
        project_name
      elsif user_report?
        user_name
      else
        default_name
      end
    end

    def client_report?
      filter.client_ids.one?
    end

    def project_report?
      filter.project_ids.one?
    end

    def user_report?
      filter.user_ids.one?
    end

    def client_name
      Client.find_by(id: filter.client_ids).name
    end

    def project_name
      Project.find_by(id: filter.project_ids).name
    end

    def user_name
      User.find_by(id: filter.user_ids).name
    end

    def default_name
      Random.rand(1000..9999)
    end

    def sanitize_text(text)
      text.parameterize(separator: "_")
    end
end
