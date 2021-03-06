class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :destroy ]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.page(params[:page]).search(params[:search])
  end

  def show
     @user = User.find(params[:id])
     @profile = @user.profile
     @micropost = @user.micropost.page(params[:page])
     # @profile = @user.profile.paginate(page: params[:page])

     @room_id = message_room_id(current_user, @user)
     @messages = Message.recent_in_room(@room_id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    params[:role].each do | di1,di2 |
      if di2 == "1"
         @user.role = di1
      end
    end
    if @user.save
      log_in @user
      flash[:success] = "Welcome!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # 更新に成功した場合を扱う。
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def message_room_id(first_user, second_user)
    first_id = first_user.id.to_i
    second_id = second_user.id.to_i
    if first_id < second_id
      "#{first_user.id}-#{second_user.id}"
    else
      "#{second_user.id}-#{first_user.id}"
    end
  end


  private
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :role)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
