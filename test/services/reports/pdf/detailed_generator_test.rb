require "test_helper"

class Reports::Pdf::DetailedGeneratorTest < ActiveSupport::TestCase
  setup do
    @manager = users(:franco)

    # == Clients
    @client_plum = clients(:plum)

    # == Projects
    @project_plum_www = projects(:one)

    # == Users
    [ "alan", "grace", "linus" ].each do |name|
      User.create!(first_name: name, last_name: "plum", email_address: "#{name}@plum.com.ar", password: "123456")
    end

    # == Assign user to projects
    @project_plum_www.project_assignments.create!(user: User.find_by(first_name: "alan"), role: :member)

    # == Assign manager to project
    @project_plum_www.project_assignments.create!(user: @manager, role: :manager)

    # == Time entries
    start_date = Date.current.beginning_of_month
    end_date = Date.current.end_of_month

    # No project
    TimeEntry.create!(
      date: start_date + 1.day, duration_minutes: 20, user: User.find_by(first_name: "alan"), description: "Test 🔥"
    )
    TimeEntry.create!(
      date: start_date + 1.day, duration_minutes: 50, user: User.find_by(first_name: "grace"), description: "Test"
    )

    # Plum project
    TimeEntry.create!(
      date: start_date + 1.day, duration_minutes: 20, user: User.find_by(first_name: "alan"), description: "Test",
      project: @project_plum_www
    )

    filter = Report::DetailedFilter.new(
      start_date: start_date,
      end_date: end_date,
      current_user: @manager
    )

    @generator = Reports::Pdf::DetailedGenerator.new(filter)
    @output_file = Reports::Pdf::DetailedGenerator::SYSTEM_FILE_NAME
  end

  teardown do
    File.delete(@output_file) if File.exist?(@output_file)
  end

  test "generates a PDF file" do
    @generator.generate
    assert File.exist?(@output_file), "PDF file was not generated"
  end

  test "the report includes a summarize and footer" do
    @generator.generate
    pdf_file = File.read(@output_file)
    text_analysis = PDF::Inspector::Text.analyze(pdf_file)

    start_date = Date.current.beginning_of_month.strftime("%d/%m/%Y")
    end_date = Date.current.end_of_month.strftime("%d/%m/%Y")

    assert_includes(text_analysis.strings, "Total Hours: 1h 30m")
    assert_includes(text_analysis.strings, "#{start_date} - #{end_date}")

    assert_includes(text_analysis.strings, "Generated using Plock")
  end

  test "the report includes grouped projects" do
    @generator.generate
    pdf_file = File.read(@output_file)
    text_analysis = PDF::Inspector::Text.analyze(pdf_file)

    array_text = text_analysis.strings
    text = array_text.join(" ")

    # Time entries without project
    assert_includes(array_text, "Project: N/A")
    assert_includes(array_text, "1h 10m")
    assert_includes(text, "02/01/2025 Alan Plum Test 00:20")
    assert_includes(text, "02/01/2025 Grace Plum Test 00:50")

    # Time entries with project
    assert_includes(array_text, "Project: www site")
    assert_includes(array_text, "0h 20m")
    assert_includes(text, "02/01/2025 Alan Plum Test 00:20")
  end
end
