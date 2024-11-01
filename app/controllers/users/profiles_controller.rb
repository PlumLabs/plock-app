class Users::ProfilesController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_profile_path(@user), notice: "Updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email_address, :password, :password_confirmation)
    end
end
