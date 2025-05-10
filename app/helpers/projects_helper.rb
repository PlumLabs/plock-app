module ProjectsHelper
  PIE_CHART_COLORS = %w[
    #6366f1 #10b981 #fbbf24 #ec4899
    #3b82f6 #8b5cf6 #f472b6 #34d399
    #059669 #65a30d #bef264 #eab308
    #f97316 #ea580c #dc2626 #ef4444
    #9333ea #d946ef #14b8a6 #0d9488
  ].freeze

  def pie_chart_colors
    PIE_CHART_COLORS
  end
end
