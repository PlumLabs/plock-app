class Ai::ModelsController < ApplicationController
  before_action :ensure_can_administrate

  def index
    @ai_models = available_chat_models
  end

  def show
    @ai_model = Ai::Model.find(params[:id])
  end

  def refresh
    Ai::Model.refresh!
    redirect_to ai_models_path, notice: "Ai::Models refreshed successfully"
  end
end
