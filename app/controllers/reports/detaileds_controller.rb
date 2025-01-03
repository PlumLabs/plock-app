class Reports::DetailedsController < ApplicationController
  before_action :ensure_can_manage_projects, unless: -> { Current.user.can_administrate? }

  def show
    @filter = Report::DetailedFilter.new(report_detailed_params.merge(current_user: Current.user))

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reports::Pdf::DetailedGenerator.new(@filter)
        send_data pdf.generate, filename: pdf.name, type: "application/pdf", disposition: "inline"
      end
    end
  end

  private
    def report_detailed_params
      return {} unless params.key?(:report)

      if params[:button] == "mobile"
        params.expect(report: [ :start_date, :end_date, mobile_project_ids: [], mobile_client_ids: [], mobile_user_ids: [] ])
      else
        params.expect(report: [ :start_date, :end_date, project_ids: [], client_ids: [], user_ids: [] ])
      end
    end
end
