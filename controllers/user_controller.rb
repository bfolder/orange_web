# User controlling & routing
module UserController
  def self.included(app)
    ## Routes ##
    app.get '/user/login/' do
    end

    app.get '/user/logout/' do
    end

    app.get '/user/create/' do
    end

    app.get '/user/auth/' do
    end

    app.get '/signup/' do
    end
  end

  ## Helpers ##
  def logged_in?
    session[:user] != nil
  end

  def generate_salt
    random = Random.new
    Array.new(User.salt.length){random.rand(33...126).chr}.join
  end
end