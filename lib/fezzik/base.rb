module Fezzik
  def self.activated=(value) @activated = value end
  def self.activated?() @activated || false end

  def self.set(name, value)
    @@settings ||= {}
    @@settings[name] = value

    if Object.public_instance_methods.include? name.to_sym
      Object.send :alias_method, :"old_#{name}", name
    end

    Object.send :define_method, name do
      Fezzik.fetch name
    end
  end

  def self.fetch(name)
    raise "No such setting: #{name}" unless @@settings.has_key?(name)
    @@settings[name]
  end

  def self.remote_task(*args, &block)
    # TODO: Parse remote_tasks's arguments and pass them to host_task. Deprecate.
  end

  def self.host_task(name, options = {}, &block)
    options = {
      :args => [],
      :deps => [],
      :roles => []
    }.merge(options)
    t = HostTask.define_task(name, { options[:args] => options[:deps] }, &block)
    t.roles = options[:roles]
  end

  def self.run(*commands)
    # TODO: When we add role functionality, check for domain setting and pass to pool.execute.
    hosts = fetch(:domain).map { |domain| "#{fetch(:user)}@#{domain}" }
    @@connection_pool ||= Weave.connect(hosts)
    @@connection_pool.execute do
      commands.each { |command| run command }
    end
  end

  def self.init(options={})
    @options = options
    @target_destination = ENV["fezzik_destination"].to_sym rescue nil
    unless options[:tasks].nil?
      $stderr.puts "Loading Fezzik tasks from #{@options[:tasks]}"
      Dir[File.join(File.expand_path(@options[:tasks]), "**", "*.rake")].sort.each { |lib| import lib }
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

  class CommandFailedError < StandardError; end
end
