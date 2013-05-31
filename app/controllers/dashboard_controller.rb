class DashboardController < ApplicationController
	protect_from_forgery
	 before_filter :confirm_logged_in

	def index
		logger.debug(@current_user.name)
	end

	def new
	end

	def create
	end

	def main
	end

	def sign_in
	end

	def pricing
	end

	def faq
	end

	def tasks
	end

	def support
		
		msg = params[:message]
       	if UserMailer.support_email(@current_user, msg).deliver
       		flash[:success] = "Your message as been sent to support, we'll contact you shortly!"
       		redirect_to :root
       	else
       		flash[:error] = "Sorry!, something wen't wrong. Please try again!"
       		redirect_to :root
       	end
  	end

	def logout
		session[:username] = nil
		redirect_to :root
	end

end
