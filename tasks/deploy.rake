require "fileutils"
require "fezzik"

include Fezzik::DSL

namespace :fezzik do
  desc "writes environment files on the server"
  host_task :write_environment do
    puts "writing environment files"
    environment = Fezzik.environments[host]
    staging_path = "/tmp/#{get :app}/environments/#{host}"
    FileUtils.mkdir_p staging_path
    File.open("#{staging_path}/environment.rb", "w") do |f|
      environment.each do |key, value|
        quote = value.is_a?(Numeric) ? '' : '"'
        f.puts "#{key.to_s.upcase} = #{quote}#{value}#{quote}"
      end
    end
    File.open("#{staging_path}/environment.sh", "w") do |f|
      environment.each { |key, value| f.puts %[export #{key.to_s.upcase}="#{value}"] }
    end
    system "rsync -az #{staging_path}/environment.* #{user}@#{host}:#{get :release_path}"
  end

  desc "stages the project for deployment in /tmp"
  task :stage do
    puts "staging project in /tmp/#{get :app}"
    FileUtils.rm_rf "/tmp/#{get :app}"
    FileUtils.mkdir_p "/tmp/#{get :app}/staged"
    # Use rsync to preserve executability and follow symlinks.
    system("rsync -aqE ./ /tmp/#{get :app}/staged")
  end

  desc "performs any necessary setup on the destination servers prior to deployment"
  host_task :setup do
    puts "setting up servers"
    run "mkdir -p #{get :deploy_to}/releases"
  end

  desc "rsyncs the project from its staging location to each destination server"
  host_task :push, :deps => [:stage, :setup] do
    puts "pushing to #{user}@#{host}:#{get :release_path}"
    # Copy on top of previous release to optimize rsync
    system "rsync -azq --copy-dest=#{get :current_path} /tmp/#{get :app}/staged/" +
           " #{user}@#{host}:#{get :release_path}"
  end

  desc "symlinks the latest deployment to /deploy_path/project/current"
  host_task :symlink do
    puts "symlinking current to #{get :release_path}"
    run "cd #{get :deploy_to} && ln -fns #{get :release_path} current"
  end

  desc "runs the executable in project/bin"
  host_task :start do
    # A very simple run_app.sh might contain the following:
    #     #!/bin/sh
    #
    #     yes &> /dev/null &
    #     echo $! > /tmp/app.pid
    puts "starting from #{(run "readlink #{get :current_path}", :output => :capture)[:stdout] }"
    run "cd #{get :current_path} && source environment.sh && ./run_app.sh"
  end

  desc "kills the application by searching for the specified process name"
  host_task :stop do
    puts "stopping app"
    run "cd #{get :current_path} && touch /tmp/app.pid && kill `cat /tmp/app.pid` || true && rm /tmp/app.pid"
  end

  desc "restarts the application"
  host_task :restart, :deps => [:stop, :start] do
  end

  desc "full deployment pipeline"
  task :deploy => [:push, :write_environment, :symlink, :restart] do
    puts "#{get :app} deployed!"
  end
end
