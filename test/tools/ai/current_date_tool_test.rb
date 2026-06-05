require "test_helper"

class Ai::CurrentDateToolTest < ActiveSupport::TestCase
  test "returns today's date in configured timezone and relative-date anchors" do
    Time.use_zone("America/Argentina/Cordoba") do
      travel_to Date.new(2026, 5, 11) do # a Monday
        result = JSON.parse(Ai::CurrentDateTool.new.execute)

        assert_equal(
          {
            "today"            => "2026-05-11",
            "yesterday"        => "2026-05-10",
            "this_week_start"  => "2026-05-11",
            "this_week_end"    => "2026-05-17",
            "last_week_start"  => "2026-05-04",
            "last_week_end"    => "2026-05-10",
            "this_month_start" => "2026-05-01",
            "this_month_end"   => "2026-05-11",
            "last_month_start" => "2026-04-01",
            "last_month_end"   => "2026-04-30",
            "timezone"         => "America/Argentina/Cordoba"
          },
          result
        )
      end
    end
  end

  test "uses Monday to Sunday for week anchors" do
    Time.use_zone("America/Argentina/Buenos_Aires") do
      travel_to Date.new(2026, 5, 13) do # a Wednesday
        result = JSON.parse(Ai::CurrentDateTool.new.execute)

        assert_equal "2026-05-11", result["this_week_start"]
        assert_equal "2026-05-17", result["this_week_end"]
        assert_equal "2026-05-13", result["this_month_end"], "this_month_end tracks today, not month end"
      end
    end
  end

  test "reports whatever Time.zone is configured" do
    # The app leaves config.time_zone unset, so the default test zone is UTC.
    assert_equal "UTC", JSON.parse(Ai::CurrentDateTool.new.execute)["timezone"]
  end
end
