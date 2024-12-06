require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  WINDOW_SIZE = [ 1400, 1400 ]
  include SystemTestHelper

  Capybara.enable_aria_label = true

  driven_by :selenium, using: :headless_chrome
end
