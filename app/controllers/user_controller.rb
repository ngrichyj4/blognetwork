class UserController < ApplicationController
  before_filter :confirm_logged_in
  
  def index
  end

  def update
  	@current_user.first_name = params[:user][:first_name]
  	@current_user.last_name = params[:user][:last_name]
  	@current_user.email = params[:user][:email]


  	if !params[:user][:password].eql? "password"
  		@current_user.password = Digest::SHA1.hexdigest(params[:user][:password])
  	end
  	if @current_user.save
  		flash[:success] = "Your account as been updated successfully"
  		redirect_to :action => 'index'
  	else
  		flash[:error] = @current_user.errors.full_messages.to_sentence
  		redirect_to :action => 'index'
  	end

  end

end
