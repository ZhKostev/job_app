source 'https://rubygems.org'

gem 'rails', '4.2.5'
gem 'mysql2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'unicorn'
gem 'quiet_assets'

group :development, :test do
  gem 'byebug'
end

group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'capistrano', :require => false
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm', :require => false
  gem "capistrano-scm-gitcopy", :require => false
  gem 'capistrano-unicorn-nginx', :require => false
end

group :test do
  gem 'simplecov' #generate code coverage
  gem 'factory_girl_rails' #generate models for tests
  gem 'rspec-rails' #rspec expectations for tests
end

