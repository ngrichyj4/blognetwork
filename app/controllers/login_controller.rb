class LoginController < ApplicationController
  protect_from_forgery
  
  layout 'login'
  
  def index
  end

  def signup

  end

  def validate_user
    if User.authenticate(params[:username], params[:password])
    	session[:username] = params[:username]
    	redirect_to :root
    else
    	flash[:error] = "Invalid user or password"
    	redirect_to :root
    end

  end

  def create

  	 @user = User.new(params[:user])
  	 if @user.save
  	 	logger.debug("User created successfuly")
  	 	session[:username] = @user.username
  	 	redirect_to :root
  	 else
  	 	flash[:error] = @user.errors.full_messages.to_sentence
  	 	logger.debug("User not created: #{flash[:error]}")
  	 	render :action => 'signup'
  	 end

  end

end
