require "stringio"
require "thread"
require "rake"
require "rake/remote_task"

$:.unshift(File.dirname(__FILE__))
require "fezzik/base.rb"
require "fezzik/environment.rb"
require "fezzik/io.rb"
require "fezzik/util.rb"

# TODO: Think about how to do domain overrides better
# TODO: Parameters to tasks

#namespace :fezzik do
  #task :run do
    #destination = ARGV[0]
    #destination = $1 if destination.match(/^to_(.+)/)
    #destination, @domain_override = destination.split(":", 2)
    #@domain_override = @domain_override.split(",") if @domain_override
    #tasks = ARGV[1..-1]
    #Rake::Task["fezzik:load_config"].invoke destination
    #begin
      #tasks.each do |task|
        #task, params = split_task_and_params(task)
        #Rake::Task["fezzik:#{task}"].invoke(*params)
      #end
      #puts "[success]".green
    #rescue SystemExit, Rake::CommandFailedError => e
      #puts "[fail]".red
      #exit 1
    #rescue Exception => e
      #puts e.message
      #puts e.backtrace
      #puts "[fail]".red
      #fail
    #end
  #end

  #task :load_config, :destination do |t, args|
    #@destination = args[:destination].to_sym
    #@environment = {}
    #require "./config/deploy.rb"
    #@servers = domain.is_a?(Array) ? domain : domain.split(",").map(&:strip)
    #compute_environment_per_server
    #puts "configuring for #{@servers.join(", ")}"
  #end

  #def destination(target, &block)
    #if target == @destination
      #block.call
      #if @domain_override
        #@domain_override.map! { |domain| domain.include?("@") ? domain : "#{user}@#{domain}" }
        #set :domain, @domain_override
      #end
    #end
  #end

  # If servers is given, then this environment variable will only apply to that server (or array of servers)
  # (these should match names given in :domain). If servers is not given, then this environment variable
  # applies to all servers.
  #def env(key, value, servers = nil)
    #servers = Array(servers) if servers
    #@environment[[key, servers]] = value
  #end

  #def compute_environment_per_server
    #@per_server_environments = Hash.new { |h, k| h[k] = {} }
    #@environment.each do |k, value|
      #key, servers = k
      #if servers
        # Allow the user to provide "user@host.com" or "host.com" when identifying servers for per-server
        # environment variables.
        #applicable_servers = @servers.select { |s1| servers.any? { |s2| s1 == s2 || s1.end_with?(s2) } }
      #else
        #applicable_servers = @servers
      #end
      #applicable_servers.each { |s| @per_server_environments[s][key] = value }
    #end
  #end

  #def split_task_and_params(task_with_params)
    #params_match = /(.+)\[(.+)\]/.match(task_with_params)
    #if params_match
      #task = params_match[1]
      #params = params_match[2].split(",")
    #else
      #task = task_with_params
      #params = nil
    #end
    #[task, params]
  #end
#end
