class Reports::DetailedsController < ApplicationController
  # GET /reports/detaileds/new
  def show
    # @reports_detailed = Reports::Detailed.new
  end

  # POST /reports/detaileds or /reports/detaileds.json
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
    # Use callbacks to share common setup or constraints between actions.
    def set_reports_detailed
      # @reports_detailed = Reports::Detailed.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def reports_detailed_params
      # params.expect(reports_detailed: [ :name, :description ])
    end
end
