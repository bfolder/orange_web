require 'dm-core'
require 'dm-validations'
require_relative 'utils/utils'

# User class representing a single user of the application
class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :email, String
  property :salt, String, :length => 32
  property :hashed_password, String, :length => 64
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :tasks

  #validates_uniqueness_of :name, :message => "That username has already been taken"
  #validates_length_of :name, :min => 5, :max => 20, :message => "Username too short. Must be between 5 and 20 characters."

  def auth(password)
    Utils::Hasher.hash_password(password, salt).eql?(hashed_password)
  end

  def formatted_name
    "#{name} <#{email}>"
  end

  def self.generate_random_password
    random = Random.new
    Array.new(8){random.rand(33...126).chr}.join
  end
end