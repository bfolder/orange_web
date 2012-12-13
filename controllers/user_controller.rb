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

    app.post '/user/edit/' do
      edit_user(params)
    end

    app.get '/account/' do
      redirect '/' unless logged_in?
      user = User.first(:hashed_password => session[:user])
      erb :account, :locals => {:user => user}
    end

    app.get '/signup/' do
      erb :signup
    end

    app.get '/forgot/' do
      erb :forgot
    end

    app.post '/reset/' do
      reset_password(params[:email])
    end
  end

  ## Database Methods ##
  def create_user(params)
    password = params[:password]
    password_check = params[:password_check]
    username = params[:username]
    email = params[:email]
    flash = validate_signup(username, password, password_check, email)

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

    salt = Utils::Hasher.generate_salt
    hashed_password = Utils::Hasher.hash_password(password, salt)
    user = User.new(
      :name => username,
      :email => email,
      :salt => salt,
      :hashed_password => hashed_password,
      :created_at => Time.now,
      :updated_at => Time.now
    )

    if user.save
      Utils::Mailer.send_to_user(user, "Hello #{user.name}. You successfully signed up to Orange.", "Your Orange account", settings.email) if settings.send_signup_mail
      session[:flash] = "Signed up successfully."
      session[:user] = user.hashed_password
      redirect "/"
    else
      session[:flash_error] = "Sign up failed, please try again."
      redirect "/"
    end
  end

  def edit_user(params)
    user =  User.first(:hashed_password => session[:user])
    email = params[:email]
    password = params[:password]
    password_check = params[:password_check]
    error = []

    if password.length == 0 && email.length == 0 && password_check.length == 0
      error << "No changes saved."
    end

    if password.length > 0 && !password.length.between?(5, 20)
      error << "Your password must be 5 to 20 characters long."
    end

    if (password.length > 0 && !password_check) || (password != password_check)
      error << "Passwords do not match. Please try again."
    end

    if email.length > 0 && !(email =~ /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/)
      error << "Please provide a valid email address."
    end

    if email == user.email
      error << "Old and new email address shouldn't be the same."
    end

    unless error.empty?
      session[:flash_error] = error
      redirect '/account/'
    else
      if email.length > 0 then user.email = email end
      if password.length > 0
        salt = Utils::Hasher.generate_salt
        hashed_password = Utils::Hasher.hash_password(password, salt)
        user.salt = salt
        user.hashed_password = hashed_password
        session[:user] = hashed_password
      end

      user.updated_at = Time.now
      user.save

      session[:flash] = "Account information updated."
      redirect '/account/'
    end
  end

  ## Helpers ##
  def validate_signup(username, password, password_check, email)
    flash = []

    if !password || password.length == 0
      flash << "Please provide a password."
    end

    if password != password_check
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

  def reset_password(email)
    unless email
      error = "No email address provided."
    end

    user =  User.first(:email => email)

    unless user
      error = "There is no registered user with this email address."
    end

    if error
      session[:flash_error] = error
      redirect '/forgot/'
    else
      new_password = User.generate_random_password
      salt = Utils::Hasher.generate_salt
      hashed_password = Utils::Hasher.hash_password(new_password, salt)
      user.salt = salt
      user.hashed_password = hashed_password
      user.updated_at = Time.now
      user.save
      Utils::Mailer.send_to_user(user, "Hello #{user.name}. You new password is #{new_password}.", "Orange account password reset", settings.email)

      session[:flash] = "Please check your mailbox for the new password."
      redirect '/'
    end
  end

  def logged_in?
    session[:user] != nil
  end
end