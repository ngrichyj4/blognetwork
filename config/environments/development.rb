Blognetwork::Application.configure do
  require 'pusher'
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false
  config.log_level = :debug     #Show crash errors.
  #> Configure pusher
    Pusher.app_id = 'XXX'
    Pusher.key = 'XXXX'
    Pusher.secret = 'XXXXX'

  #> Active Merchant
  config.after_initialize do
      ActiveMerchant::Billing::Base.mode = :production
      paypal_options = {
        :login => "XXXX",
        :password => "XXXX",
        :signature => "XXXX"
      }
      ::STANDARD_GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(paypal_options)
      ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
  end
  
  # Expands the lines which load the assets
  config.assets.debug = true
end
