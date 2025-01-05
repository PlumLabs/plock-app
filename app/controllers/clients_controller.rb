class ClientsController < ApplicationController
  before_action :ensure_can_administrate
  before_action :set_client, only: %i[ edit update destroy ]

  def index
    @clients = filter_clients(Client.all).then { search_clients(_1) }.then(&paginate)
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = Client.new(client_params)

    respond_to do |format|
      if @client.save
        format.html { redirect_to clients_path, notice: "created" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to clients_path, notice: "updated" }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @client.disable!

    respond_to do |format|
      format.html { redirect_to clients_path, status: :see_other, notice: "archived" }
    end
  end

  private
    def set_client
      @client = Client.find(params.expect(:id))
    end

    def client_params
      params.expect(client: [ :name, :email, :note, :disabled_at ])
    end

    def query_params
      return {} if params[:q].nil?

      params.expect(q: [ :name_or_email_cont, :status_eq ])
    end

    def filter_clients(scope)
      return scope if query_params.dig(:status_eq).blank?

      case query_params.dig(:status_eq)
      when "active"
        scope.active
      when "archive"
        scope.archive
      else
        scope
      end
    end

    def search_clients(scope)
      return scope if query_params.dig(:name_or_email_cont).blank?

      scope.where("name LIKE :q OR email LIKE :q", q: "%#{query_params.dig(:name_or_email_cont)}%")
    end
end
