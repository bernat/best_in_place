class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @countries = COUNTRIES_HASH

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def email_field
    @user = User.find(params[:id])
    render :action => :email_field, :layout => false
  end

  def show_ajax
    @user = User.find(params[:id])
    @countries = COUNTRIES_HASH
  end

  def double_init
    @user = User.find(params[:id])
    @countries = COUNTRIES_HASH
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    # puts "RUNNING UPDATE: #{user_params.inspect}"

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end


 private

  def user_params
    params.require(:user).permit!
  end
end
