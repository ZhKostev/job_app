set :deploy_to, '/home/test_app/test'
role :app, %w{test_app@188.166.39.104}
role :web, %w{test_app@188.166.39.104}
role :db,  %w{test_app@188.166.39.104}
server "188.166.39.104", user: 'root', roles: [:app, :web, :db], :primary => true
set :branch, "master" # TODO: staging branch should be set
set :user, "root"
set :rails_env, :staging
set :stage, :staging
set :rvm_type, :system
set :rvm_ruby_version, 'ruby-2.2.1@test'
set :deploy_via, :copy
set :default_shell, "/bin/bash -l"
