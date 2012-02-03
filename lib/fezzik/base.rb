module Fezzik
  def self.init(options={})
    @options = options
    @selected_destination = ENV["fezzik_destination"].to_sym
    unless @options[:config].nil?
      puts "Loading Fezzik config from #{@options[:config]}"
      require File.join(Dir.pwd, @options[:config]) if @options[:config]
    end
    unless options[:tasks].nil?
      puts "Loading Fezzik tasks from #{@options[:tasks]}"
      Dir[File.join(Dir.pwd, "#{options[:tasks]}/**/*.rb")].sort.each { |lib| require lib }
    end
  end

  # TODO: add domain override (through environment variable?)
  def self.destination(name, &block)
    block.call if name == @selected_destination
  end
end
