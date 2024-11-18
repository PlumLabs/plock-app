class UsersController < ApplicationController
  before_action :ensure_can_administrate
  before_action :set_user, only: %i[ destroy ]

  def index
    @users = filter_users(User.all).then { search_users(_1) }
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

    def query_params
      return {} if params[:q].nil?

      params.expect(q: [ :first_name_or_last_name_or_email_cont, :status_eq ])
    end

    def filter_users(scope)
      return scope if query_params.dig(:status_eq).blank?

      case query_params.dig(:status_eq)
      when "active"
        scope.active
      when "archive"
        scope.active.invert_where
      else
        scope
      end
    end

    def search_users(scope)
      return scope if query_params.dig(:first_name_or_last_name_or_email_cont).blank?

      scope.where("first_name LIKE :q OR last_name LIKE :q OR email_address LIKE :q",
                  q: "%#{query_params.dig(:first_name_or_last_name_or_email_cont)}%")
    end
end
