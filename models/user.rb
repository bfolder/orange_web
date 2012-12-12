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