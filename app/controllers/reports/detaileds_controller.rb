class Reports::DetailedsController < ApplicationController
  def show
    @filters = Report::DetailedFilter.new(report_detailed_params.merge(current_user: Current.user))
  end

  def create
    # @reports_detailed = Reports::Detailed.new(reports_detailed_params)

    # respond_to do |format|
    #   if @reports_detailed.save
    #     format.html { redirect_to @reports_detailed, notice: "Detailed was successfully created." }
    #     format.json { render :show, status: :created, location: @reports_detailed }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @reports_detailed.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  private
    def report_detailed_params
      return {} unless params.key?(:report)

      params.expect(report: [ :start_date, :end_date, project_ids: [], client_ids: [], user_ids: [] ])
    end
end
