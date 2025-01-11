require "test_helper"

class Reports::FileNameGeneratorTest < ActiveSupport::TestCase
  test "generates file name for a single client as PDF by default" do
    filter = Report::DetailedFilter.new(
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 1, 31),
      client_ids: [ clients(:plum).id ]
    )

    file_name = Reports::FileNameGenerator.new(filter).name

    # Asserts format: "report_plum_01-01-2024--31-01-2024.pdf"
    assert_match(/report_plum_\d{2}-\d{2}-\d{4}--\d{2}-\d{2}-\d{4}\.pdf/, file_name)
  end

  test "generates file name for a single project as PDF by default" do
    filter = Report::DetailedFilter.new(
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 1, 31),
      project_ids: [ projects(:one).id ]
    )

    file_name = Reports::FileNameGenerator.new(filter).name

    assert_match(/report_www_site_\d{2}-\d{2}-\d{4}--\d{2}-\d{2}-\d{4}\.pdf/, file_name)
  end

  test "generates file name for a single user as PDF by default" do
    filter = Report::DetailedFilter.new(
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 1, 31),
      user_ids: [ users(:franco).id ]
    )

    file_name = Reports::FileNameGenerator.new(filter).name

    assert_match(/report_franco_colapinto_\d{2}-\d{2}-\d{4}--\d{2}-\d{2}-\d{4}\.pdf/, file_name)
  end

  test "uses default name and date range if no client_ids, project_ids, or user_ids" do
    filter = Report::DetailedFilter.new(
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 1, 31)
    )

    file_name = Reports::FileNameGenerator.new(filter).name

    assert_match(/report_\d{4}_\d{2}-\d{2}-\d{4}--\d{2}-\d{2}-\d{4}\.pdf/, file_name)
  end

  test "uses default name and date range if many client_ids, project_ids, or user_ids" do
    filter = Report::DetailedFilter.new(
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 1, 31),
      client_ids: [ 1, 2 ],
      project_ids: [ 1, 2 ],
      user_ids: [ 1, 2 ]
    )

    file_name = Reports::FileNameGenerator.new(filter).name

    assert_match(/report_\d{4}_\d{2}-\d{2}-\d{4}--\d{2}-\d{2}-\d{4}\.pdf/, file_name)
  end
end
