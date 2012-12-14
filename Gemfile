source 'https://rubygems.org'

gem 'sinatra'
gem 'data_mapper'
gem 'dm-is-list'
gem 'data_objects'
gem 'mail'

group :production do
  gem 'thin'
  gem "pg"
  gem "dm-postgres-adapter"
end

group :development, :test do
  gem "sqlite3"
  gem "dm-sqlite-adapter"
end

group :test do
  gem 'rspec'
  gem 'rack-test'
end