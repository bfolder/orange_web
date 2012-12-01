require 'dm-core'
require 'dm-validations'
require 'dm-is-list'

# Simple Task class representing the model of the application
class Task
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :done, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user, :required => true
  is :list, :scope => :user_id
  #validates_presence_of :title
end