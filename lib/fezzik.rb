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
    tasks.each do |task|
      Rake::Task["fezzik:#{task}"].invoke
    end
  end

  task :load_config, :destination do |t, args|
    @destination = args[:destination].to_sym
    @environment = {}
    require "config/deploy.rb"
    puts "configuring for #{domain}"
  end

  def destination(target, &block)
    block.call if target == @destination
  end

  def env(key, value)
    @environment[key] = value
  end
end
