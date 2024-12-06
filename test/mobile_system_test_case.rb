require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  WINDOW_SIZE = [ 375, 667 ]
  include SystemTestHelper

  Capybara.enable_aria_label = true

  driven_by :selenium, using: :headless_chrome, screen_size: WINDOW_SIZE

  setup do
    # force the mobile window size before each test
    current_window.resize_to(*WINDOW_SIZE)
  end

  teardown do
    # go back to the default window size to avoid side effects
    current_window.resize_to(*ApplicationSystemTestCase::WINDOW_SIZE)
  end
end
