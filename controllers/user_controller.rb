# User controlling & routing
class Orange < Sinatra::Base
  ## Routes ##
  get '/users/' do
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