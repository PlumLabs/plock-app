class Ai::ChatsController < ApplicationController
  before_action :ensure_can_administrate
  before_action :set_ai_chat, only: [ :show, :destroy ]
  rescue_from RubyLLM::ConfigurationError, with: :llm_configuration_error

  def index
    @ai_chats = Current.user.ai_chats.order(updated_at: :desc).limit(25)
  end

  def new
    @ai_chat = Ai::Chat.new
    @selected_model = params[:model]
    @chat_models = available_chat_models
  end

  def create
    prompt = params.dig(:ai_chat, :prompt)

    if prompt.present?
      @ai_chat = Current.user.ai_chats.create!(model: params.dig(:ai_chat, :model).presence)
      Ai::ChatResponseJob.perform_later(@ai_chat.id, prompt)

      redirect_to @ai_chat, notice: "Ai::chat was successfully created."
    else
      head :unprocessable_entity
    end
  end

  def show
    @ai_message = @ai_chat.ai_messages.build
  end

  def destroy
    @ai_chat.destroy!
    redirect_to ai_chats_path, notice: "Ai::chat was successfully destroyed.", status: :see_other
  end

  private
    def set_ai_chat
      @ai_chat = Current.user.ai_chats.includes(:ai_model).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :forbidden
    end

    def llm_configuration_error(exception)
      render partial: "error", locals: { error: exception.message }, status: :internal_server_error
    end
end
