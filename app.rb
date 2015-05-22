require 'rubygems'
require 'sinatra'
require 'sinatra/contrib'
require 'omniauth-twitter'
require 'pp'

set :environment, :development

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

# index, prolly wont get used
get '/' do
  haml :index, format: :html5
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

# if authenticated, callback will redirect to the form
get '/builder' do
  haml :builder, format: :html5
end
