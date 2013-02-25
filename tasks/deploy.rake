require "fileutils"
require "fezzik"

include Fezzik::DSL

namespace :fezzik do
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
    puts "pushing to #{host}:#{get :release_path}"
    # Copy on top of previous release to optimize rsync
    system "rsync -azq --copy-dest=#{get :current_path} /tmp/#{get :app}/staged/ #{host}:#{get :release_path}"
  end

  desc "symlinks the latest deployment to /deploy_path/project/current"
  host_task :symlink do
    puts "symlinking current to #{get :release_path}"
    run "cd #{get :deploy_to} && ln -fns #{get :release_path} current"
  end

  desc "runs the executable in project/bin"
  host_task :start do
    puts "starting from #{(run "readlink #{get :current_path}", :output => :capture)[:stdout] }"
    run "cd #{get :current_path} && (source environment.sh || true) && ./bin/run_app.sh"
  end

  desc "kills the application by searching for the specified process name"
  host_task :stop do
    # Replace YOUR_APP_NAME with whatever is run from your bin/run_app.sh file.
    # If you'd like to do this nicer you can save the PID of your process with `echo $! > app.pid`
    # in the start task and read the PID to kill here in the stop task.
    # puts "stopping app"
    # run "(kill -9 `ps aux | grep 'YOUR_APP_NAME' | grep -v grep | awk '{print $2}'` || true)"
  end

  desc "restarts the application"
  host_task :restart, :deps => [:stop, :start] do
  end

  desc "full deployment pipeline"
  task :deploy => [:push, :write_environment, :symlink, :restart] do
    puts "#{get :app} deployed!"
  end
end
