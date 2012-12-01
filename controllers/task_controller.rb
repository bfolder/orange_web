# Task controlling & routing
module TaskController
  def self.included(app)
    ## Routes ##
    app.get '/tasks/' do
      tasks = Task.all :order => [:order_index.desc]
      erb :index, {:locals => {:tasks => tasks}}
    end

    app.post '/tasks/' do
      create_task params
      redirect '/'
    end

    app.put '/tasks/:id' do
      update_task params
      redirect '/'
    end

    app.delete '/tasks/:id' do
      delete_task params
      redirect '/'
    end

    # Use these to 'fake' PUT / DELETE methods if not available
    app.post '/tasks/update/:id' do
      update_task params
      redirect '/'
    end

    app.get '/tasks/delete/:id' do
      delete_task params
      redirect '/'
    end
  end

  ## Data Methods ##
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
end