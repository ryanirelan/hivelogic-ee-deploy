################################################################################
# Capistrano recipe for deploying ExpressionEngine websites from GitHub        #
# By Dan Benjamin - http://example.com/                                        #
################################################################################


##### Settings #####

# the name of your website - should also be the name of the directory
set :application, "example.com"

# the name of your system directory, which you may have customized
set :ee_system, "system"

# the path to your virtual-hosts directory on the server up to
# but NOT including the name of the website, specified above
set :deploy_to, "/var/www/sites/#{application}"

# the git-clone url for your repository
set :repository, "git@github.com:you/project.git"

# the branch you want to clone (default is master)
set :branch, "master"

# the name of the deployment user-account on the server
set :user, "deploy"







##### You shouldn't need to edit below unless you're customizing #####

# Additional SCM settings
set :scm, :git
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache
set :copy_strategy, :checkout
set :keep_releases, 3
set :use_sudo, false
set :copy_compression, :bz2

# Roles
role :app, "#{application}"
role :web, "#{application}"
role :db,  "#{application}", :primary => true

# Deployment process
after "deploy:update", "deploy:cleanup" 
after "deploy", "deploy:set_permissions", "deploy:create_symlinks"

# Custom deployment tasks
namespace :deploy do

  desc "This is here to overide the original :restart"
  task :restart, :roles => :app do
    # do nothing but overide the default
  end

  task :finalize_update, :roles => :app do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    # overide the rest of the default method
  end

  desc "Create additional EE directories and set permissions after initial setup"
  task :after_setup, :roles => :app do
    # create upload directories
    run "mkdir #{deploy_to}/#{shared_dir}/config"
    run "mkdir #{deploy_to}/#{shared_dir}/assets"
    run "mkdir #{deploy_to}/#{shared_dir}/assets/images"
    run "mkdir #{deploy_to}/#{shared_dir}/assets/images/avatars/uploads"
    run "mkdir #{deploy_to}/#{shared_dir}/assets/images/captchas"
    run "mkdir #{deploy_to}/#{shared_dir}/assets/images/member_photos"
    run "mkdir #{deploy_to}/#{shared_dir}/assets/images/pm_attachments"
    run "mkdir #{deploy_to}/#{shared_dir}/assets/images/signature_attachments"
    run "mkdir #{deploy_to}/#{shared_dir}/assets/images/uploads"
    # set permissions
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/avatars/uploads"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/captchas"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/member_photos"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/pm_attachments"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/signature_attachments"
    run "chmod 777 #{deploy_to}/#{shared_dir}/assets/images/uploads"
  end

  desc "Set the correct permissions for the cache folders"
  task :set_permissions, :roles => :app do
    # run "chmod 777 #{current_release}/images/avatars/uploads/"
    # run "chmod 777 #{current_release}/images/captchas/"
    # run "chmod 777 #{current_release}/images/member_photos/"
    # run "chmod 777 #{current_release}/images/pm_attachments/"
    # run "chmod 777 #{current_release}/images/signature_attachments/"
    # run "chmod 777 #{current_release}/images/uploads/"
    run "chmod 777 #{current_release}/#{ee_system}/cache/"
  end

  desc "Create symlinks to shared data such as config files and uploaded images"
  task :create_symlinks, :roles => :app do
    # the precious config file
    run "ln -s #{deploy_to}/#{shared_dir}/config/config.php #{current_release}/#{ee_system}/config.php" 
    # standard image upload directories
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/avatars/uploads #{current_release}/images/avatars/uploads"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/captchas #{current_release}/images/avatars/captchas"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/member_photos #{current_release}/images/avatars/member_photos"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/pm_attachments #{current_release}/images/avatars/pm_attachments"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/signature_attachments #{current_release}/images/avatars/signature_attachments"
    run "ln -s #{deploy_to}/#{shared_dir}/assets/images/uploads #{current_release}/images/avatars/uploads"
  end

  desc "Clear the ExpressionEngine caches"
  task :clear_cache, :roles => :app do
    run "if [ -e #{current_release}/#{ee_system}/cache/db_cache ]; then rm -r #{current_release}/#{ee_system}/cache/db_cache/*; fi"
    run "if [ -e #{current_release}/#{ee_system}/cache/page_cache ]; then rm -r #{current_release}/#{ee_system}/cache/page_cache/*; fi"
    run "if [ -e #{current_release}/#{ee_system}/cache/magpie_cache ]; then rm -r #{current_release}/#{ee_system}/cache/magpie_cache/*; fi"
  end

end
