class ClientsController < ApplicationController
  before_action :ensure_can_administrate
  before_action :set_client, only: %i[ edit update destroy ]

  def index
    @clients = if query = search_query[:name_or_email_cont]
      Client.where("name LIKE :q OR email LIKE :q", q: "%#{query}%")
    else
      Client.all
    end
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
      params.expect(client: [ :name, :email, :note ])
    end

    def search_query
      return {} if params[:q].nil?

      params.expect(q: [ :name_or_email_cont ])
    end
end
