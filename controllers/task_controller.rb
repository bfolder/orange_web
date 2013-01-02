# Task controlling & routing
module TaskController
  def self.included(app)
    ## Routes ##

    ## HTML ##
    app.get '/tasks/' do
      redirect '/' unless logged_in?

      user = User.first(:hashed_password => session[:user])
      tasks = Task.all(:user => user, :order => [:position])
      erb :index, {:locals => {:tasks => tasks}}
    end

    app.post '/tasks/' do
      create_task(params) if logged_in?
      redirect '/'
    end

    app.put '/tasks/:id' do
      update_task(params) if logged_in?
      redirect '/'
    end

    app.delete '/tasks/:id' do
      delete_task(params) if logged_in?
      redirect '/'
    end

    # Use these to 'fake' PUT / DELETE methods if not available
    app.post '/tasks/update/:id' do
      update_task(params) if logged_in?
      redirect '/'
    end

    app.get '/tasks/delete/:id' do
      delete_task(params) if logged_in?
      redirect '/'
    end

    app.get '/tasks/clear/' do
      clear_tasks if logged_in?
      redirect '/'
    end
  end

  ## JSON ##
  app.get '/tasks.json' do
    redirect '/' unless logged_in?
    content_type :json

    user = User.first(:hashed_password => session[:user])
    tasks = Task.all(:user => user, :order => [:position])
    tasks.to_json
  end

  ## Helpers
  def task_warning(params)
    flash = "Couldn't find task. Try again later."
    if params[:title] && params[:title].length > 0
      flash = "The task has no title."
    end
    session[:flash_error] = flash
  end

  ## Data Methods ##
  def create_task(params = [])
    task = Task.new(:title => params[:title], :created_at => Time.now, :updated_at => Time.now)
    unless task
      task_warning(params)
      return
    end
    user = User.first :hashed_password => session[:user]
    user.tasks << task
    task.save
    task.move(:top)
    task.save
  end

  def update_task(params = [])
    task = Task.first(:conditions => {:id => Integer(params[:id])})
    unless task
      task_warning params
      return
    end

    if params[:position]
      position =  Integer(params[:position])
      task.move(position) if position && position != task.position
    end

    task.done = params[:done] == 'on'
    task.title = params[:title] if(params[:title])
    task.updated_at = Time.now
    task.save
  end

  def delete_task(params = [])
    task = Task.first(:conditions => {:id => Integer(params[:id])})
    unless task
      session[:flash_error] = "Couldn't find task. Try again later."
      return
    end
    task.move(:lowest)
    task.destroy
  end

  def clear_tasks
    Task.all(:conditions => {:done => true}).each do |task|
      task.move(:lowest)
      task.destroy
    end
  end
end