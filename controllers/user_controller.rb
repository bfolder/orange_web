require_relative '../models/user'

# User controlling & routing
module UserController
  def self.included(app)
    ## Routes ##
    app.get '/user/signin/' do
      redirect '/' if logged_in?
      erb :signin
    end

    app.get '/user/logout/' do
      session[:user] = nil
      session[:flash] = "You have logged out successfully."
      redirect '/'
    end

    app.post '/user/create/' do
      create_user(params)
    end

    app.post '/user/auth/' do
      user = User.first(:name => params[:username])

      unless user
        session[:flash_error] = "User doesn't exist."
        redirect "/"
      end

      auth = user.auth(params[:password])

      if auth
        if user.save
          session[:user] = user.hashed_password
        else
          session[:flash_error] = "There was an error logging in, please try again."
        end
      else
        session[:flash_error] = "Incorrect Password."
      end

      redirect '/'
    end

    app.get '/signup/' do
      erb :signup
    end
  end

  ## Database Methods ##
  def create_user(params)
    password = params[:password]
    password_again = params[:password_again]
    username = params[:username]
    email = params[:email]
    flash = validate_signup(username, password, password_again, email)

    unless flash.empty?
      session[:flash_error] = flash
      redirect '/signup/'
    end

    user = User.first(:name => username)

    if user
      session[:flash_error] = "That username has already been taken."
      redirect '/signup/'
    end

    user = User.first(:email => email)

    if user
      session[:flash_error] = "That email address is already in our database."
      redirect '/signup/'
    end

    salt = generate_salt
    hashed_password = Utils::Hasher.hash_password password, salt
    user = User.new(
      :name => username,
      :email => email,
      :salt => salt,
      :hashed_password => hashed_password,
      :created_at => Time.now,
      :updated_at => Time.now
    )

    if user.save
      Utils::Mailer.send_to_user user, "Hello #{user.name}. You successfully signed up to Orange.", "Your Orange account", settings.email if settings.send_signup_mail
      session[:flash] = "Signed up successfully."
      session[:user] = user.hashed_password
      redirect "/"
    else
      session[:flash_error] = "Sign up failed, please try again."
      redirect "/"
    end
  end

  ## Helpers ##
  def validate_signup(username, password, password_again, email)
    flash = []

    if !password || password.length == 0
      flash << "Please provide a password."
    end

    if password != password_again
      flash << "Passwords do not match. Please try again."
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