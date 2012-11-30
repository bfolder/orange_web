require 'dm-core'
require 'dm-validations'

# Simple Task class representing the model of the application
class Task
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :order_index, Integer, :default => 0
  property :done, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user

  validates_presence_of :title
end