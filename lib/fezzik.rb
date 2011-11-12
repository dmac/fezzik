require "stringio"

namespace :fezzik do
  task :run do
    destination = ARGV[0]
    destination = $1 if destination.match(/^to_(.+)/)
    destination, @domain_override = destination.split(":", 2)
    @domain_override = @domain_override.split(",") if @domain_override
    tasks = ARGV[1..-1]
    Rake::Task["fezzik:load_config"].invoke destination
    begin
      tasks.each do |task|
        task, params = split_task_and_params(task)
        Rake::Task["fezzik:#{task}"].invoke(*params)
      end
      puts "[success]".green
    rescue SystemExit, Rake::CommandFailedError => e
      puts "[fail]".red
      exit 1
    rescue Exception => e
      puts e.message
      puts e.backtrace
      puts "[fail]".red
      fail
    end
  end

  task :load_config, :destination do |t, args|
    @destination = args[:destination].to_sym
    @environment = {}
    require "./config/deploy.rb"
    servers = domain
    servers = domain.join(", ") if domain.is_a?(Array)
    puts "configuring for #{servers}"
  end

  def destination(target, &block)
    if target == @destination
      block.call
      if @domain_override
        @domain_override.map! { |domain| domain.include?("@") ? domain : "#{user}@#{domain}" }
        set :domain, @domain_override
      end
    end
  end

  def env(key, value)
    @environment[key] = value
  end

  def capture_output(&block)
    output = StringIO.new
    $stdout = output
    block.call
    return output.string
  ensure
    $stdout = STDOUT
  end

  def split_task_and_params(task_with_params)
    params_match = /(.+)\[(.+)\]/.match(task_with_params)
    if params_match
      task = params_match[1]
      params = params_match[2].split(",")
    else
      task = task_with_params
      params = nil
    end
    [task, params]
  end
end
