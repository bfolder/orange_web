require 'dm-core'
require 'dm-validations'
require "digest/sha2"

# This Hasher module hashes user passwords
module Hasher
  def hash password, salt
    Digest::SHA2.hexdigest password + salt
  end
end

# User class representing a single user of the application
class User
  include DataMapper::Resource
  include Hasher

  property :id, Serial
  property :name, String
  property :salt, String, :length => 32
  property :hashed_password, String, :length => 64

  has n, :tasks, :required => true

  validates_uniqueness_of :name, :message => "That username has already been taken"
  validates_length_of :name, :min => 5, :max => 20, :message => "Username too short. Must be between 5 and 20 characters."

  def auth password
    if hash(password, salt).eql?(hashed_password) then true else false end
  end
end