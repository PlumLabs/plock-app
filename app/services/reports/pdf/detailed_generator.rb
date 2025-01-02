class Reports::Pdf::DetailedGenerator
  def initialize(filter, output_file = "report.pdf")
    @data = filter
    @output_file = output_file
  end

  def generate
    Prawn::Document.generate(@output_file) do |pdf|
      add_styles(pdf)
      add_header(pdf)
      add_summary(pdf)
      add_tables(pdf)
      add_footer(pdf)
    end
  end

  private

  def add_styles(pdf)
    pdf.font_size 10
    pdf.font "Helvetica"
  end

  def add_header(pdf)
    pdf.text "Detailed Report", size: 18, style: :bold, align: :left
    pdf.move_down 10
    pdf.text "01/12/2024 - 31/12/2024", size: 12, align: :left
    pdf.move_down 10
  end

  def add_summary(pdf)
    total_hours = @data.total_minutes
    pdf.text "Total Hours: #{format('%.2f', total_hours)}", size: 12
    pdf.move_down 20
  end

  def add_tables(pdf)
    table_data = @data.results.map do |entry|
      [ entry.date, entry.user.name, entry.description, entry.duration ]
    end

    add_table(pdf, table_data)
  end

  def add_table(pdf, table_data)
    metadata = [
      { content: "Project: F40 Renewal - Client: Ferrari SA and FIAT", colspan: 3, text_color: "7D7D7D", font_style: :bold },
      { content: "4500:30", colspan: 1, text_color: "7D7D7D", font_style: :bold }
    ]

    columns =  [ "Date", "Team Member", "Task", "Hours" ]

    column_widths = [
      70, # Date
      130, # Team Member
      270, # Task
      70  # Hours
    ]

    cell_style = {
      borders: [ :bottom ],
      border_width: 0.5,
      border_color: "cccccc"
    }

    entries = [ metadata ] + [ columns ] + table_data

    pdf.table(entries, header: true, column_widths: column_widths, cell_style: cell_style) do |t|
      t.row(1).style(font_style: :bold) # header
    end

    pdf.move_down 20
  end

  def add_footer(pdf)
    pdf.text "Generated using Plock", align: :center, size: 10, style: :italic
  end
end
