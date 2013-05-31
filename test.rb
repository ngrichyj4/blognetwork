require 'net/http'

def up?(site)
  Net::HTTP.new(site).head('/').kind_of? Net::HTTPOK
end

p up? 'http://www.heroku.com' #=> true
