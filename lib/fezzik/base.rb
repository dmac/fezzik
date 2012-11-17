module Fezzik
  def self.activated=(value) @activated = value end
  def self.activated?() @activated || false end

  def self.set(name, value)
    @@settings ||= {}
    @@settings[name] = value
  end

  def def self.fetch(name)
    raise "No such setting: #{name}" unless @@settings.has_key?(name)
    @@settings[name]
  end

  def self.init(options={})
    @options = options
    @target_destination = ENV["fezzik_destination"].to_sym rescue nil
    unless options[:tasks].nil?
      puts "Loading Fezzik tasks from #{@options[:tasks]}"
      Dir[File.join(Dir.pwd, "#{@options[:tasks]}/**/*.rake")].sort.each { |lib| import lib }
    end
  end

  def self.destination(name, &block)
    block.call if name == @target_destination
  end

  def self.target_destination
    @target_destination ||= nil
  end
end
