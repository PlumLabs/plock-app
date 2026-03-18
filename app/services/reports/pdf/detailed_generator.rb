class Reports::Pdf::DetailedGenerator
  SYSTEM_FILE_NAME = Rails.root.join("tmp", "report.pdf").to_s.freeze

  delegate :name, to: :file_name_generator

  def initialize(filter)
    @data = Reports::Pdf::DetailedReportData.new(filter)
    @file_name_generator = Reports::FileNameGenerator.new(filter)
  end

  def generate(output_path = SYSTEM_FILE_NAME)
    Prawn::Document.generate(output_path) do |pdf|
      add_styles(pdf)
      add_header(pdf)
      add_summary(pdf)
      add_tables(pdf)
      add_footer(pdf)
    end
  end

  private

    attr_reader :data, :file_name_generator

    TABLE_COLUMNS = [ "Date", "Member", "Task", "Hours" ].freeze
    TABLE_COLUMNS_WIDTH = [ 70, 130, 270, 70 ].freeze
    TABLE_CELL_STYLE = { borders: [ :bottom ], border_width: 0.5, border_color: "cccccc" }.freeze

    def add_styles(pdf)
      pdf.font_size 10
      pdf.font "Helvetica"
    end

    def add_header(pdf)
      pdf.text "Time Report", size: 18, style: :bold, align: :left

      pdf.image Rails.root.join("app", "assets", "images", "report_logo.png"),
                at: [ pdf.bounds.right - 90, pdf.cursor + 35 ],
                width: 70

      pdf.move_down 10
      pdf.text date_range, size: 12, align: :left
      pdf.move_down 10
    end

    def add_summary(pdf)
      pdf.text "Total Hours: #{data.total_hours}", size: 12
      pdf.move_down 20
    end

    def add_tables(pdf)
      data.grouped_by_project_results.each do |group_result|
        group_data = {
          project_name: group_result[:project_name],
          total_group_duration: group_result[:group_duration]
        }

        table_data = group_result[:results].map do |entry|
          [ entry.date.strftime("%d/%m/%Y"), sanitize_text(entry.user.name), sanitize_text(entry.description), entry.duration ]
        end

        add_table(pdf, table_data, group_data)
      end
    end

    def add_table(pdf, table_data, group_data)
      table_group_data = [
        { content: "Project: #{group_data[:project_name] || 'N/A'}", colspan: 3, text_color: "7D7D7D", font_style: :bold },
        { content: group_data[:total_group_duration], colspan: 1, text_color: "7D7D7D", font_style: :bold }
      ]

      entries = [ table_group_data ] + [ TABLE_COLUMNS ] + table_data

      pdf.table(entries, header: true, column_widths: TABLE_COLUMNS_WIDTH, cell_style: TABLE_CELL_STYLE) do |t|
        t.row(1).style(font_style: :bold) # header
      end

      pdf.move_down 12
    end

    def add_footer(pdf)
      pdf.text "Generated using Plock", align: :center, size: 10, style: :italic
    end

    def date_range
      [ data.start_date, data.end_date ].compact.map { |date| date.strftime("%d/%m/%Y") }.join(" - ")
    end

    def sanitize_text(text)
      text.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "?")
    end
end
