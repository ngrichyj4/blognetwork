require 'bundler/capistrano'
set :user, 'root'
set :domain, 'XXXXX'
set :applicationdir, "/var/www/blognetwork"
#set :bundle_cmd, '$HOME/.bashrc && bundle'

set :default_environment, {
  'PATH' => "/opt/ruby-enterprise-1.8.7-2012.02/bin/:$PATH"
}
 
set :scm, 'git'
set :repository,  "ssh://root@XXXXX/var/www/blognetwork.git"
set :git_enable_submodules, 1 # if you have vendored rails
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
 
# roles (servers)
role :web, domain
role :app, domain
role :db,  domain, :primary => true
 
# deploy config
set :deploy_to, applicationdir
set :deploy_via, :export
 
# additional settings
default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/home/user/.ssh/id_rsa)            # If you are using ssh_keysset :chmod755, "app config db lib public vendor script script/* public/disp*"set :use_sudo, false
 
# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end





##set :application, "set your application name here"
##set :repository,  "set your repository location here"

##set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

##role :web, "your web-server here"                          # Your HTTP server, Apache/etc
##role :app, "your app-server here"                          # This may be the same as your `Web` server
##role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
##role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end