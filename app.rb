require 'sinatra'
require 'omniauth-twitter'
register Sinatra::ConfigFile
config_file 'config/secrets.yml'

configure do
  enable :sessions
  use OmniAuth::Builder do
    provider :twitter, settings.twitter_api_key, settings.twitter_api_secret
  end
end



get '/' do
  erb :index
end
