class BlogController < ApplicationController
	before_filter :confirm_logged_in

	def group
		group = Group.new(params[:group])
		if group.save
			flash[:success] = "#{group.name} blog group created successfully"
			@current_user.groups << group
			redirect_to :root
		else
			flash[:error] = group.errors.full_messages.to_sentence
			redirect_to :root
		end
	end

	def express
		result = blog_total_amount_in_cents(params[:qty])
		response = EXPRESS_GATEWAY.setup_purchase(result['total'],
		    :ip                => request.remote_ip,
		    :items => [{:name => "Blogs Creation", :quantity => result['qty'],:description => "You're been charged as per your plan's blog creation fee per blog. If not subscribed to any montly plan, the default fee is $15.", :amount => result['amount']}],
		    :return_url        => url_for(:action=>:success, :total => result['total'], :grp_id => params[:grp_id], :qty => params[:qty], :only_path=>false),
		    :cancel_return_url => url_for(:action=>:cancelled, :only_path=>false)
  		)
  		p response
  		redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
	end

	def success
		redirect_to :root unless params[:token]

		details_response = EXPRESS_GATEWAY.details_for(params[:token])

		if !details_response.success?
		    @message = details_response.message
		    flash[:error] = "#{@message}"
		    redirect_to :root
		else
			purchase = EXPRESS_GATEWAY.purchase(params[:total].to_i,
			    :ip       => request.remote_ip,
			    :payer_id => details_response.payer_id,
			    :token    => params[:token]
			  )
			if !purchase.success?
			    @message = purchase.message
			    flash[:error] = "#{@message}"
		    	redirect_to :root
			else
				task = Task.create(:usr_id => @current_user.id, :grp_id => params[:grp_id], :qty => params[:qty], :status => "processing", :action => 'create_blog')
				@current_user.tasks << task
				@super_admin.tasks << task if !@current_user.eql? @super_admin
				UserMailer.task_email(@current_user, task).deliver
			  	flash[:success] = "Thanks for the payment!, Please check your Queued Tasks to see the status of your order."
				redirect_to :root
			 end

			
		end

		
	end

	def cancelled
		flash[:error] = "Your blogs we're not created because you cancelled the payment. Please try again!"
		redirect_to :root
	end


	def new
		@blog = Blog.find(params[:id])
		if @current_user.blogs.include? @blog
			if @blog.username.nil? || @blog.password.nil?
				flash[:error] = "You need to add a username and password for this blog before you can publish content."
				redirect_to :action => :configure, :id => @blog.id
			else
				unless params[:dwarn]
					flash[:warning] = "Please make sure you've enabled XMLRPC on this blog. To enable login to your WordPress dashboard, navigate to Setting's menu and choose Writing option, there you can enable XML-RPC."
				end
				@content = session[:content]
				@content_title = session[:content_title]
				render 'new', :layout => 'login'
			end

		else
			flash[:error] = "You do not have access to this blog"
			redirect_to :root
		end
	end

	

	def post
		@blog = Blog.find(params[:id])
		if @current_user.blogs.include? @blog
		require 'xmlrpc/client'

			post = {
			'post_title'       	 => "#{params[:title]}",
			'post_content'       => "#{params[:editor1]}",
			'post_status'		 => "publish"
			}

			# initialize the connection - Change

			connection = XMLRPC::Client.new2("#{@blog.url}xmlrpc.php")  #Replace your wordpress URL
			begin
				result = connection.call('wp.newPost', 1,decrypt(@blog.username, @current_user.email),decrypt(@blog.password, @current_user.email),post) #For New Creating the Post
				session[:content] = nil
				session[:content_title] = nil
				flash[:success] = "Your post was published successfully."
			rescue Exception => error
				flash[:error] = error.message
				session[:content] = "#{params[:editor1]}"
				session[:content_title] = "#{params[:title]}"
			end
			redirect_to :action => :new, :dwarn => "1", :id => @blog.id	
		else
			flash[:error] = "You do not have access to this blog"
			redirect_to :root
		end

	end

	def configure
		@blog = Blog.find(params[:id])
		if @current_user.blogs.include? @blog
			render 'configure', :layout => 'login'
		else
			flash[:error] = "You do not have access to this blog"
			redirect_to :root
		end
	end


	def update
		#Save blog user & password

		blog = Blog.find(params[:blog_id])
	  if @current_user.blogs.include? blog	
		blog.username = encrypt(params[:username], @current_user.email)
		blog.password = encrypt(params[:password], @current_user.email) if params[:password] != "password"
		# Add Domain Task
		if blog.custom_domain.nil? || !(blog.custom_domain == params[:custom_domain])
			logger.debug("Create new task")
			task = Task.create(:usr_id => @current_user.id, :grp_id => blog.group_id, :blg_id => blog.id, :domain => params[:custom_domain], :status => "processing", :action => 'add_domain')
			@current_user.tasks << task
			@super_admin.tasks << task if !@current_user.eql? @super_admin
			UserMailer.task_email(@current_user, task).deliver
		end	

		blog.custom_domain = params[:custom_domain]
		if blog.save
			flash[:success] = "Your blog as been configured successfully, please check your Queued Tasks if you modified custom domain name."
		else
			flash[:error] = "Sorry we couldn't configure this blog. Please try again!"
		end
		redirect_to :action => :configure, :id => blog.id
	  else
	  	flash[:error] = "You do not have access to this blog"
	  	redirect_to :action => :configure, :id => blog.id
	  end
	end

end
