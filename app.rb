require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'logger'
# Load 'controllers'
require './controllers/task_controller'
require './controllers/user_controller'

# Setup database (sqlite 3 in this case)
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/orange.sqlite3")

# Load model classes
require './models/task'
require './models/user'

DataMapper.finalize
DataMapper.auto_upgrade!

# Main application class
class Orange < Sinatra::Base
  include TaskController, UserController

  # Configure environment
  enable :sessions
  set :root, File.dirname(__FILE__)
  set :views, './views/'
  set :public_folder, './public/'

  ## Logging ##
  before do
    puts "Params: #{params}"
    #puts "Session: #{session}"
  end

  ## Helpers ##
  helpers do
    def display_flash
      if session[:flash]
        flash = session[:flash]
        session[:flash] = nil
        flash
      end
    end
  end

  ## Routes ##
  get '/' do
    if logged_in?
      redirect '/tasks/'
    else
      redirect '/user/login/'
    end
  end

  get '/404' do
    erb :not_found, :layout => false
  end

  not_found do
    redirect '/404'
  end
end