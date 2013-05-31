class TaskController < ApplicationController
	before_filter :confirm_logged_in
	before_filter :is_super_admin
	before_filter :is_get, :only => :add_domain

	#==============
    #>  Realtime stuff here
    #===================

	def index
		Pusher['logs'].trigger('msg', { :message => "Hello there!" })
	end

	def delete
		task = Task.find(params[:id])
		if @current_user.tasks.delete task
			flash[:success] = "Task successfully removed."
		else
			flash[:error] = "Sorry, we couldn't remove this task. Please try again!"
		end
		redirect_to :controller => :dashboard, :action => :tasks
	end

	def run
		@task = Task.find(params[:id])
		if @task.action == 'add_domain'
			redirect_to :action => 'add_domain', :id => @task.id and return
		else
			redirect_to :action => :create_blog, :id => @task.id 
		end
	end

	def add_domain
		
		puts request.env["HTTP_REFERER"]
		logger.debug request.env["HTTP_REFERER"]
		@task = Task.find(params[:id])
		domains = Array.new
		domains << domain_name(@task.domain)
		domains << "www.#{domain_name(@task.domain)}"
		@previous_path = current_path
		switch_path("#{current_path}/custom_wordpress")

		begin
			#> Login to Heroku
			heroku_login("ngrichyj4@gmail.com", "XXXXX")

			#> TODO: Implement add heroku domain 
			heroku_add_domain(domains,Domainatrix.parse("#{Blog.find(@task.blg_id).url}").subdomain)
			#> When done switch path to previous
			switch_path(@previous_path)
			#> Update task status
			@task.status = "completed"
			@task.save

			#> Return status
			@status = [1]
		rescue Exception => error
			#> When done switch path to previous
			switch_path(@previous_path)

			logger.debug("#{error.message}")
			push_logs("#{error.message}")
			@status = [0]
		end

		respond_to do |format|
	        format.json {render :json => @status and return}
	    end

	end

	def create_blog
		@task = Task.find(params[:id])

		@previous_path = current_path
		switch_path("#{current_path}/custom_wordpress")
	if @task.qty.to_i > 0
		begin
			#Login to Heroku
			heroku_login("ngrichyj4@gmail.com", "XXXXX")

			#> Create heroku blog
			@task.qty.to_i.times do
				heroku_create(RandomWord.adjs.next, @task.grp_id)
			end

			#> When done switch path to previous
			switch_path(@previous_path)

			#> Keep alive blogs
			blog_urls = return_blogs
			logger.debug("Added #{blog_urls} to heroku_keepalive")
			push_logs("Added #{blog_urls} to heroku_keepalive")
			
			heroku_keepalive(blog_urls)

			#> Update task status
			@task.status = "completed"
			@task.qty = 0
			@task.save

			#> Return status
			@status = [1]
		rescue Exception => error
			#> When done switch path to previous
			switch_path(@previous_path)

			logger.debug("#{error.message}")
			push_logs("#{error.message}")
			@status = [0]
		end
	else
		@status = [1]
	end
		respond_to do |format|
	        format.json {render :json => @status}
	    end


	end


	
end
