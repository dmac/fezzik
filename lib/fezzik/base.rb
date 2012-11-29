module Fezzik
  def self.activated=(value) @activated = value end
  def self.activated?() @activated || false end

  def self.init(options={})
    @options = options
    @target_destination = ENV["fezzik_destination"].to_sym rescue nil
    unless options[:tasks].nil?
      puts "Loading Fezzik tasks from #{@options[:tasks]}"
      Dir[File.join(Dir.pwd, "#{@options[:tasks]}/**/*.rake")].sort.each { |lib| import lib }
    end
  end

  def self.destination(*names, &block)
    @destinations ||= Set.new
    @destinations.merge(names)
    block.call if names.include?(@target_destination)
  end

  def self.target_destination
    @target_destination ||= nil
  end

  def self.destinations
    @destinations ||= Set.new
  end
end
