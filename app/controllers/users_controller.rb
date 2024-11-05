class UsersController < ApplicationController
  before_action :ensure_can_administrate
  before_action :set_user, only: %i[ destroy ]

  def index
    @users = if query = search_query[:first_name_or_last_name_or_email_cont]
      User.where("first_name LIKE :q OR last_name LIKE :q OR email_address LIKE :q", q: "%#{query}%")
    else
      User.all
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: "created" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "destroyed" }
    end
  end

  private
    def set_user
      @user = User.find(params.expect(:id))
    end

    def user_params
      params.expect(user: [ :first_name, :last_name, :email_address, :password, :role ])
    end

    def search_query
      return {} if params[:q].nil?

      params.expect(q: [ :first_name_or_last_name_or_email_cont ])
    end
end
