# This is the configuration file for fezzik.
# Define variables here as you would for Vlad the Deployer.
# A full list of variables can be found here:
#     http://hitsquad.rubyforge.org/vlad/doco/variables_txt.html

set :app, "app"
set :deploy_to, "/opt/#{app}"
set :release_path, "#{deploy_to}/releases/#{Time.now.strftime("%Y%m%d%H%M")}"
set :local_path, Dir.pwd
set :user, "root"


# Each destination is a set of machines and configurations to deploy to.
# You can deploy to a destination from the command line with:
#     fez to_dev deploy
#
# :domain can be an array if you are deploying to multiple hosts.
#
# You can set environment variables that will be loaded at runtime on the server
# like this:
#     env :rack_env, "production"

destination :dev do
  set :domain, "#{user}@dev.example.com"
end

destination :prod do
  set :domain, "#{user}@prod.example.com"
end
