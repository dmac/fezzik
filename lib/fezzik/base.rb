module Fezzik
  def self.init(options={})
    @options = options
    @target_destination = ENV["fezzik_destination"].to_sym rescue nil
    unless options[:tasks].nil?
      puts "Loading Fezzik tasks from #{@options[:tasks]}"
      Dir[File.join(Dir.pwd, "#{@options[:tasks]}/**/*.rake")].sort.each { |lib| import lib }
    end
  end

  # TODO: add domain override (through environment variable?)
  def self.destination(name, &block)
    block.call if name == @target_destination
  end

  def self.target_destination
    @target_destination ||= nil
  end
end
