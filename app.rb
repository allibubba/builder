require 'rubygems'
require 'rack/cache'
require 'sinatra'
require 'sinatra/contrib'
require 'omniauth-twitter'
require 'pp'
require "haml"
require 'dotenv'
Dotenv.load

set :environment, :development
set :public_folder, 'public'
config_file 'config/secrets.yml'

use Rack::Session::Cookie, :key => 'builder_app',
  :path => '/',
  :expire_after => 14400, # In seconds
  :secret => 'secret_stuff'

configure do
  use OmniAuth::Builder do
    provider :twitter, settings.twitter_api_key, settings.twitter_api_secret
  end
end

helpers do
  def current_user
    !session[:uid].nil?
  end
end

#redirect to static page if accessed without
get "/" do
  cache_control :public, :max_age => 36000
  haml :index, format: :html5
end

#form must be subitted via ajax to processing system
post "/" do
  status 503
  body 'ERROR 503, you cannot submit here' 
end

# auth routes
get '/auth/twitter/callback' do
  session[:uid] = env['omniauth.auth']['uid']
  redirect to('/builder')
end

get '/auth/failure' do
  status 503
  body 'ERROR 503, there was a problem with authentication'
end

# if authenticated, show form, else go to login page
get '/builder' do
  pp session[:uid].nil?
  if session[:uid]
    send_file File.join(settings.public_folder, 'builder.html')
  else
    redirect '/'
  end
end



# clear session data
get '/logout' do
  session[:uid] = nil
  redirect to('/')
end
