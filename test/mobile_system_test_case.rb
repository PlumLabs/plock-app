require "application_system_test_case"

class MobileSystemTestCase < ApplicationSystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [ 375, 667 ]
end
