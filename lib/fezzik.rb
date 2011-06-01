namespace :fezzik do
  task :run do
    if ARGV.size == 0
      puts "    Usage: fez to_destination task"
      exit 1
    end
    destination = ARGV[0]
    destination = $1 if destination.match(/to_(.+)/)
    tasks = ARGV[1..-1]
    Rake::Task["fezzik:load_config"].invoke destination
    begin
      tasks.each do |task|
        Rake::Task["fezzik:#{task}"].invoke
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
    block.call if target == @destination
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
end
