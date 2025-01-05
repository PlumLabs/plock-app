  module Pagination
    extend ActiveSupport::Concern

    DEFAULT_PER_PAGE = 100.freeze

    included do
      helper_method :page_no, :per_page, :total_pages, :total_count, :paginate_offset
    end

    def total_pages
      (total_count / per_page.to_f).ceil
    end

    def page_no
      params[:page]&.to_i || 1
    end

    def per_page
      params[:per_page]&.to_i || DEFAULT_PER_PAGE
    end

    def paginate_offset
      (page_no-1)*per_page
    end

    def total_count
      @total_count ||= 1
    end

    def paginate
      -> do
        self.total_count = _1.count
        _1.limit(per_page).offset(paginate_offset)
      end
    end

    private

      def total_count=(value)
        @total_count = value
      end
  end
