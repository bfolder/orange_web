# Task controlling & routing
class Orange < Sinatra::Base
  ## Routes ##
  get '/tasks/' do
    tasks = Task.all :order => [:order_index.desc]
    erb :index, {:locals => {:tasks => tasks}, :views => './views/'}
  end

  post '/tasks/' do
    create_task params
    redirect '/'
  end

  put '/tasks/:id' do
    update_task params[:id], params
    redirect '/'
  end

  delete '/tasks/:id' do
    delete_task params[:id], params
    redirect '/'
  end

  # Use these to 'fake' PUT / DELETE methods if not available
  post '/tasks/update/:id' do
    update_task params
    redirect '/'
  end

  get '/tasks/delete/:id' do
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
end