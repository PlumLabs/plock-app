require "test_helper"

class PaginationTest < ActiveSupport::TestCase
  class TestController < ActionController::Base
    include Pagination

    attr_accessor :params

    def initialize(params = {})
      @params = params
    end

    def test_paginate(collection)
      collection.then(&paginate)
    end
  end

  setup do
    @controller = TestController.new
  end

  test "default values" do
    assert_equal 1, @controller.total_count, "Default total_count should be 1"
    assert_equal 10, @controller.per_page, "Default per_page should be 10"
    assert_equal 1, @controller.page_no, "Default page_no should be 1"
    assert_equal 0, @controller.paginate_offset, "Default paginate_offset should be 0"
  end

  test "calculated total pages" do
    @controller.instance_variable_set(:@total_count, 25)
    assert_equal 3, @controller.total_pages, "total_pages should calculate correctly"
  end

  test "pagination offset with params" do
    @controller.params = { page: 3, per_page: 10 }
    assert_equal 20, @controller.paginate_offset, "paginate_offset should calculate correctly"
  end

  test "paginate lambda sets total_count and limits scope" do
    collection = User.all
    paginate_sql = @controller.test_paginate(collection).to_sql

    assert_equal 2, @controller.total_count
    assert paginate_sql.include?("LIMIT"), "paginate should limit"
    assert paginate_sql.include?("OFFSET"), "paginate should offset"
  end
end
