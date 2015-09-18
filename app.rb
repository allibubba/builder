require 'rubygems'
require 'rack/cache'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/base'
require 'sinatra/config_file'
require 'omniauth-twitter'
require 'pp'
require 'haml'
require 'dotenv'
Dotenv.load

# The program allows authentication via
# OmniAuth's Twitter provider.
#
# Author::    Jackson Oates
# License::   Distributes under the same terms as Ruby
class MyApp < Sinatra::Base
  register Sinatra::ConfigFile
  set :environments, %w(development test production staging)
  set :environment, :development
  set :public_folder, 'public'
  configure :staging, :development do
    enable :logging
  end

  config_file 'config/secrets.yml'

  use Rack::Session::Cookie,
      key: 'builder_app',
      path: '/',
      expire_after: 14_400,
      secret: 'secret_stuff'

  configure do
    use OmniAuth::Builder do
      provider :twitter, MyApp.twitter_api_key, MyApp.twitter_api_secret
    end
  end

  helpers do
    def current_user
      !session[:uid].nil?
    end
  end

  # redirect to static page if accessed without
  get '/' do
    # cache_control :public, :max_age => 36000
    haml :index, format: :html5
  end

  # form must be subitted via ajax to processing system
  post '/' do
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
    if session[:uid]
      # send_file File.join(settings.public_folder, 'builder.html')
      haml :builder, format: :html5
    else
      redirect '/'
    end
  end

  # clear session data
  get '/logout' do
    session[:uid] = nil
    redirect to('/')
  end
end
