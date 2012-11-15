require "bundler/setup"
require "scope"
require "minitest/autorun"

require "fezzik"
include Fezzik::DSL
include Rake::DSL

ENV["fezzik_destination"] = "vagrant"
Fezzik.init

VAGRANT_DOMAIN = "fezzik-vagrant"

destination :vagrant do
  set :user, "vagrant"
  set :domain, VAGRANT_DOMAIN
end

def setup_vagrant
  system("mkdir -p ~/.ssh; touch ~/.ssh/config")
  ssh_configured = `grep "fezzik-vagrant" ~/.ssh/config`.size > 0
  unless ssh_configured
    puts "Generating vagrant ssh config in ~/.ssh/config"
    ssh_config = `vagrant ssh-config`.gsub("Host default", "\nHost fezzik-vagrant") << "  LogLevel QUIET\n"
    system("echo '#{ssh_config}' >> ~/.ssh/config")
  end

  vagrant_running = `vagrant status | grep "running"`.size > 0
  unless vagrant_running
    puts "Starting vagrant (run 'vagrant halt' to shutdown)"
    system("vagrant up")
  end
end

def fez(task, params = nil)
  Rake::Task["fezzik:#{task}"].invoke(params)
end

def assert_file_exists(path)
  assert_equal path, `ssh vagrant@fezzik-vagrant ls #{path} 2> /dev/null`.chomp
end

def refute_file_exists(path)
  refute_equal path, `ssh vagrant@fezzik-vagrant ls #{path} 2> /dev/null`.chomp
end

setup_vagrant()
