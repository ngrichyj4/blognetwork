class ApplicationController < ActionController::Base
  protect_from_forgery
  require 'open3'
  
  def confirm_logged_in
      unless session[:username]
        #> render  :action => 'welcome', :layout => false
        #> redirect_to :controller => 'newsfeed', :action => 'welcome'
        redirect_to :root
        return false
      else
      	@current_user = User.find_by_username(session[:username])
        @super_admin = User.find_by_super_admin(true)
        return true
      end
  end

  def is_get
     if request.get? 
        return true
      else
        redirect_to :root
        return false
      end

  end


  def is_super_admin

    if @current_user.super_admin.nil?
      flash[:error] = "You do not have access to this url"
      redirect_to :root
      return false
    else
      return true
    end

  end

  def dec_user_id(crypt)
    cipher = Gibberish::AES.new("p4ssw0rd")
    return cipher.dec("#{crypt}").to_i
  end

  def encrypt(data, key)
     cipher = Gibberish::AES.new("#{key}")
     return cipher.enc("#{data}")
  end

  def decrypt(data, key)
    cipher = Gibberish::AES.new("#{key}")
    return cipher.dec("#{data}")
  end


  # This will be called when soemone first subscribes
  def sign_up_user(custom, plan_id, subscr_id)
    @id = dec_user_id(custom)
    user = User.find(@id)
    user.plan_id = plan_id
    user.subscr_id = subscr_id
    user.save
    logger.debug("sign_up_user (#{user.name})")
  end

  # This will be called if someone cancels a payment
  def cancel_subscription(plan_id, subscr_id)
    user = User.find_by_subscr_id(subscr_id)
    user.active = false if user
    user.plan_id = nil if user
    user.save if user
    logger.debug("cancel_subscription (#{user.name})") if user

  end

  # This will be called if a subscription expires
  def subscription_expired(plan_id, subscr_id)
    
     user = User.find_by_subscr_id(subscr_id)
     logger.debug("subscription_expired (#{user.name})") if user
     user.active = false if user
     user.plan_id = nil if user
     user.save if user
  end

  # Called if a subscription fails
  def subscription_failed(plan_id, subscr_id)
    
    user = User.find_by_subscr_id(subscr_id)
    logger.debug("subscription_failed (#{user.name})") if user
    user.active = false if user
    user.plan_id = nil if user
    user.save if user
  end

   # Called each time paypal collects a payment
  def subscription_payment(custom, plan_id, subscr_id)
     if custom
      @id = dec_user_id(custom)
      @user = User.find(@id)
    else
      @user = User.find_by_subscr_id(subscr_id) 
    end
     logger.debug("recurrent_payment_received (#{@user.name})") if @user
     @user.plan_id = plan_id if @user
     @user.active = true if @user
     @user.save  if @user
  end

  def domain_name(uri)
    require "addressable/uri"
    
    Addressable::URI.heuristic_parse(uri, :scheme => "http") \
      .host[/\w+\.\w+(\.\w{2})?\Z/]
  end

  def push_logs(data)
    Pusher['logs'].trigger('msg', { :message => "#{data}" })
  end

   def blog_total_amount_in_cents(qty)
        #Pricing in cents
       @plan_id_price = {"1" => "900", "2" => "600", "3" => "400"}
       if @current_user.plan_id.nil? || @current_user.plan_id == '0'
          @blog_pricing = "1500"
       else
          @blog_pricing = @plan_id_price["#{@current_user.plan_id}"].to_i
       end

       total = qty.to_i * @blog_pricing.to_i
       amount = @blog_pricing.to_i

       return @current_user.demo_user == true ?  {'total' => 1, 'amount' => 1, 'qty' => 1} : {'total' => total, 'amount' => amount, 'qty' => qty.to_i}
    end


  #============================================
  # HEROKU SPECIFIC METHODS
  #============================================
  #Return current path
  def current_path
    return Dir.pwd
  end

  #Change path to specified
  def switch_path(to)
    Dir.chdir "#{to}"
    logger.debug("Switched path to #{current_path}: switch_path")
    push_logs("Switched path to #{current_path}: switch_path")
  end

  # Login to Heroku
  def heroku_login(user, pass)
  Open3.pipeline_rw("heroku login") {|stdin, stdout, wait_thrs|
    stdin.puts "#{user}"
    stdin.puts "#{pass}"
    stdin.close     # send EOF to sort.
    #p stdout.read   #=> ""
    push_logs(stdout.read) #Display log in view
    logger.debug(p stdout.read)  #Display log in logfile
    

  }
  end

  # Add Domain to blog
  def heroku_add_domain(domain, app)
    system("heroku domains:clear --app=#{app}") #Clear any existing domains
    domain.each do |naked_domain|
      push_logs("Adding #{naked_domain} to #{app}")
      Open3.pipeline_rw("heroku domains:add #{naked_domain} --app=#{app}") {|stdin, stdout, wait_thrs|
        stdin.close     # send EOF to sort.
        #p stdout.read   #=> ""
        logger.debug(p stdout.read)  #Display log in logfile
        push_logs(stdout.read) #Display log in view

      }
    end
  end

  def heroku_dbsetup(app_name)

    push_logs "Adding mysql cleardb:ignite to #{app_name}"
    logger.debug "Adding mysql cleardb:ignite to #{app_name}"
    Open3.pipeline_rw("heroku addons:add cleardb:ignite --app=#{app_name}") {|stdin, stdout, wait_thrs|
             #@heroku_db = stdout.read   #=> ""
             logger.debug(p stdout.read)  #Display log in logfile
             push_logs(stdout.read) #Display log in view
    }
    Open3.pipeline_rw("heroku config --app=#{app_name}") {|stdin, stdout, wait_thrs| @heroku_db = stdout.read }
    push_logs "Added DATABASE_URL=#{@heroku_db.split[5]}"
    system("heroku config:add DATABASE_URL=#{@heroku_db.split[5]} --app=#{app_name}")
  end


  def heroku_keepalive(blogs)
    Open3.pipeline_rw("heroku config:add ENDPOINTS=#{blogs} --app=keepalive-myblogs") {|stdin, stdout, wait_thrs|
             logger.debug(p stdout.read)  #Display log in logfile
             push_logs(stdout.read) #Display log in view
    }
    
  end

  def return_blogs
    Blog.all.map { |f| f.url.chomp("/") }.join ','
  end


  def heroku_create(branch, grp_id)
    
    Open3.pipeline_rw("heroku create --remote #{branch}") {|stdin, stdout, wait_thrs|
             @heroku_app = stdout.read   #=> ""
    }

    push_logs "Logs is: #{@heroku_app}"
    logger.debug "Logs is: #{ p @heroku_app}"

    push_logs "Processing git add ."
    logger.debug "Processing git add ."
    system("git add .")

    push_logs "Processing git commit #{branch}"
    logger.debug "Processing git commit #{branch}"
    system("git commit -m #{branch}")

    push_logs "Processing git push #{branch} master"
    logger.debug "Processing git push #{branch} master"
    system("git push #{branch} master")

    blog = Blog.new(:url => @heroku_app.split[6], :status => "active", :branch => "#{branch}")
    if blog.save
      group = Group.find(grp_id)
      group.blogs << blog

      #Setup MySQL
      heroku_dbsetup(Domainatrix.parse("#{Blog.find(blog.id).url}").subdomain)

      push_logs("Added #{blog.url} to #{group.name}")
      logger.debug("Added #{blog.url} to #{group.name}")
    else
      push_logs("Unable to save blog to #{group.name}")
      logger.debug("Unable to save blog to #{group.name}")
    end

  end

  
  

end
