# Task controlling & routing
module TaskController
  def self.included(app)
    ## Routes ##
    app.get '/tasks/' do
      redirect '/' unless logged_in?

      user = User.first :hashed_password => session[:user]
      tasks = Task.all :user => user, :order => [:position]
      erb :index, {:locals => {:tasks => tasks}}
    end

    app.post '/tasks/' do
      return unless logged_in?

      create_task(params)
      redirect '/'
    end

    app.put '/tasks/:id' do
      redirect '/' unless logged_in?

      update_task(params)
      redirect '/'
    end

    app.delete '/tasks/:id' do
      redirect '/' unless logged_in?

      delete_task(params)
      redirect '/'
    end

    # Use these to 'fake' PUT / DELETE methods if not available
    app.post '/tasks/update/:id' do
      redirect '/' unless logged_in?

      update_task(params)
      redirect '/'
    end

    app.get '/tasks/delete/:id' do
      redirect '/' unless logged_in?

      delete_task(params)
      redirect '/'
    end

    app.get '/tasks/clear/' do
      return unless logged_in?

      clear_tasks
      redirect '/'
    end
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
    task.destroy
  end

  def clear_tasks
    Task.all(:conditions => {:done => true}).each(&:destroy)
  end
end