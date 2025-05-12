require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  WINDOW_SIZE = [ 375, 667 ]
  include SystemTestHelper

  Capybara.enable_aria_label = true

  driven_by :selenium, using: :headless_chrome, screen_size: WINDOW_SIZE do |options|
    options.add_argument("--guest")
  end

  # https://github.com/rails/rails/blob/31c060c38225d36a73b5d4787cccc0cb7e1c944a/actionpack/lib/action_dispatch/system_test_case.rb#L69
  # As screen_size is ignored on headless_chrome with selenium, we need to resize the window manually
  setup do
    # force the mobile window size before each test
    current_window.resize_to(*WINDOW_SIZE)
  end

  teardown do
    # go back to the default window size to avoid side effects when running other tests
    default_window_size = defined?(ApplicationSystemTestCase::WINDOW_SIZE) ? ApplicationSystemTestCase::WINDOW_SIZE : WINDOW_SIZE
    current_window.resize_to(*default_window_size)
  end
end
