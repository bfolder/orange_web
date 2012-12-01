require_relative '../models/user'

# User controlling & routing
module UserController
  include Hasher

  def self.included(app)
    ## Routes ##
    app.get '/user/login/' do
    end

    app.get '/user/logout/' do
      session[:user] = nil
      session[:flash] = "You have logged out successfully"
      redirect '/'
    end

    app.post '/user/create/' do
      create_user params
    end

    app.get '/user/auth/' do
      redirect '/'
    end

    app.get '/signup/' do
      erb :signup
    end
  end

  ## Database Methods ##
  def create_user params
    password = params[:password]
    username = params[:username]
    email = params[:email]
    flash = validate_signup

    unless flash.empty?
      session[:flash] = flash.join('<br />')
      redirect '/signup/'
    end

    user = User.first(:name => username)

    if user
      session[:flash] = "That username has been taken"
      redirect "/signup"
    end

    salt = generate_salt
    hashed_password = hash_password password, salt
    user = User.new(
      :name => params[:name],
      :salt => salt,
      :hashed_password => hashed_password,
      :created_at => Time.now,
      :updated_at => Time.now
    )

    if user.save
      session[:flash] = "Signed up successfully"
      session[:user] = user.hashed_password
      redirect "/"
    else
      session[:flash] = "Signup failed, please try again"
      redirect "/"
    end
  end

  ## Helpers ##
  def validate_signup
    flash = []

    if !password || password.length == 0
      flash << "Please provide a password."
    end

    if !username || username.length == 0
      flash << "Please provide a username."
    end

    if !username.length.between?(5, 20)
      flash << "Your username must be 5 to 20 characters long."
    end

    if !email || !(email =~ /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/)
      flash << "Please provide a valid email address."
    end

    if !password || !password.length.between?(5, 20)
      flash << "Your password must be 5 to 20 characters long."
    end

    flash
  end

  def logged_in?
    session[:user] != nil
  end

  def generate_salt
    random = Random.new
    Array.new(User.salt.length){random.rand(33...126).chr}.join
  end
end