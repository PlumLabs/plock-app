class Users::ProfilesController < ApplicationController
  before_action :set_user
  before_action :ensure_current_user, unless: -> { Current.user.can_administrate? }
  before_action :ensure_can_administrate, only: [ :destroy ]

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_profile_path(@user), notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.deactivate
    redirect_to edit_user_profile_path(@user), notice: "User was deactivated."
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def user_params
      if Current.user.can_administrate?
        admin_user_params
      else
        regular_user_params
      end
    end

    def admin_user_params
      params.require(:user).permit(:first_name, :last_name, :email_address, :password, :password_confirmation, :disabled_at, :role)
    end

    def regular_user_params
      params.require(:user).permit(:first_name, :last_name, :password, :password_confirmation)
    end
end
