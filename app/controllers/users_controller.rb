class UsersController < ApplicationController
  before_action :ensure_can_administrate
  before_action :set_user, only: %i[ create ]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_user
      @user = User.find(params.expect(:id))
    end

    def user_params
      params.expect(user: [ :first_name, :last_name, :email_address, :password, :password_confirmation ])
    end
end
