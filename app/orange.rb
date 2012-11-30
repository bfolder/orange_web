require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'logger'

# Setup database (sqlite 3 in this case)
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/orange.sqlite3")

# Load model classes
require_relative "model/task"
require_relative "model/user"

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
    tasks = Task.all :order => [:order_index.desc]
    erb :index, :locals => {:tasks => tasks}
  end

  post '/' do
    create_task params
    redirect '/'
  end

  put '/:id' do
    update_task params[:id], params
    redirect '/'
  end

  delete '/:id' do
    delete_task params[:id], params
    redirect '/'
  end

  not_found do
    status 404
    'not found'
  end

  # Use these to 'fake' PUT / DELETE methods if not available
  post '/update/:id' do
    update_task params
    redirect '/'
  end

  get '/delete/:id' do
    delete_task params
    redirect '/'
  end

  ## Methods ##
  def create_task params = []
    task = Task.create(:title => params[:title], :created_at => Time.now, :updated_at => Time.now)
    return unless task
    task.order_index = task.id
    task.save
  end

  def update_task params = []
    task = Task.first(:conditions => {:id => Integer(params[:id])})
    return unless task
    task.done = params[:done] == 'on'
    task.title = params[:title] if(params[:title])
    task.save
  end

  def delete_task params = []
    task = Task.first(:conditions => {:id => Integer(params[:id])})
    return unless task
    task.destroy
  end

  # Helpers
  def logged_in?
    session[:user] != nil
  end

  def generate_salt
    random = Random.new
    Array.new(User.salt.length){random.rand(33...126).chr}.join
  end
end