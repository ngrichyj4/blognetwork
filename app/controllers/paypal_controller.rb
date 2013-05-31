class PaypalController < ApplicationController
	protect_from_forgery :except => [:paypal_ipn, :success, :cancel]

  def success
  	#@plan = {'1' => "Micro", '2' => "Starter", "3" => "Business"}
  	if params[:auth]
  		flash[:success] = "Your account as now been upgraded. Thank you!"
  	end
  	redirect_to :root
  end

  def cancel
  	#> @plan = {'1' => "Micro", '2' => "Starter", "3" => "Business"}
  	flash[:error] = "You cancelled the subscription, please try again!"
  	redirect_to :root
  end

 

  #> process the PayPal IPN POST
  def paypal_ipn
  	logger.debug("IPN receieved data")

    #> use the POSTed information to create a call back URL to PayPal
    query = 'cmd=_notify-validate'
    request.params.each_pair {|key, value| query = query + '&' + key + '=' + 
      value if key != 'register/pay_pal_ipn.html/pay_pal_ipn' }

    paypal_url = 'www.paypal.com' 
    #> paypal_url = 'www.paypal.com'
    #> if ENV['RAILS_ENV'] == 'development'
    #>  paypal_url = 'www.sandbox.paypal.com'
    #> end
    logger.debug(paypal_url)

    #> Verify all this with paypal
    #> http = Net::HTTP.start(paypal_url, 80)
    #> response = http.post('/cgi-bin/webscr', query)
    #> logger.debug(response)
    #> logger.debug(query)
    #> http.finish

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    page = agent.get("https://www.paypal.com/cgi-bin/webscr?#{query}")
    response = page.body.strip
    logger.debug("Paypal responsed with --> #{response}")
    logger.debug("https://www.paypal.com/cgi-bin/webscr?#{query}")
    item_name = params[:item_name]
    item_number = params[:item_number]
    payment_status = params[:payment_status]
    txn_type = params[:txn_type]
    subscr_id = params[:subscr_id]
    custom = params[:custom]

    #> Paypal confirms so lets process.
    #> logger.debug("response data: "+response.body)
    #> if response && response.body.chomp == 'VERIFIED' 
     if response == "VERIFIED"
      if txn_type == 'subscr_signup'
        logger.debug("User signed up")
        sign_up_user(custom, item_number, subscr_id)
      elsif txn_type == 'subscr_cancel'
        cancel_subscription(item_number, subscr_id)
      elsif txn_type == 'subscr_eot'
        subscription_expired(item_number, subscr_id)
      elsif txn_type == 'subscr_failed'
        subscription_failed(item_number, subscr_id)
      elsif txn_type == 'subscr_payment' && payment_status == 'Completed'
        subscription_payment(custom, item_number, subscr_id)
      end
      logger.debug("Subscription processed by IPN item_name: #{item_name} ")
      render :text => 'OK'

    else
      logger.debug("Subscription failed item_name: #{item_name} ")
      render :text => 'ERROR'
    end
  end
end
