require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemTestHelper

  Capybara.enable_aria_label = true

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
