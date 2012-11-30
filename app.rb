require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'logger'

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
  ## Logging ##
  before do
    puts "Params: #{params}"
  end

  ## Routes ##
  get '/' do
    redirect '/tasks/'
  end

  not_found do
    status 404
    'not found'
  end
end