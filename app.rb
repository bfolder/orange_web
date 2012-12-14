require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'logger'

# Load 'controllers'
require './controllers/task_controller'
require './controllers/user_controller'

# Setup database (sqlite or something else defined in DATABASE_URL)
#DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/db/orange.sqlite3")

# Test with in-memory store
configure :test do
  DataMapper.setup(:default, "sqlite::memory:")
end

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
  set :logger, Logger.new(STDOUT)
  set :root, File.dirname(__FILE__)
  set :views, './views/'
  set :public_folder, './public/'
  set :email, 'admin@orangeapp.com'
  set :send_notifications, false

  configure :development do
    enable :logging
  end

  ## Logging & Stuff ##
  before do
    return unless settings.logging
    puts "Params: #{params}"
    puts "Session: #{session}"
  end

  ## Routes ##
  get '/' do
    if logged_in?
      redirect '/tasks/'
    else
      redirect '/user/signin/'
    end
  end

  get '/404' do
    erb :not_found, :layout => false
  end

  not_found do
    redirect '/404'
  end
  
  ## Helpers ##
  helpers do
    def display_flashes
      flashes = [session[:flash], session[:flash_error]]
      flash_output = ''
      flashes.each_with_index do |flash, index|
        if flash
          flash_message = flash
          flash_message = '<ul>'
          if flash.respond_to? :each
            flash.each do |message|
              flash_message << "<li>#{message}</li>"
            end
          else
            flash_message << "<li>#{flash}</li>"
          end

          flash_message << '</ul>'
          addclass = ''

          if index == 1
            addclass = 'error'
          end

          flash_output << "<div class='flash #{addclass}'>#{flash_message}</div>"
        end
      end
      session[:flash] = nil
      session[:flash_error] = nil
      flash_output
    end
  end
end