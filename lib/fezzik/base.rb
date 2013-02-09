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
    # Parts to handle:
    #   - name
    #   - dependencies
    #   - arguments
    #   - roles
    # Possible values of `args`:
    #   [:name]
    #   [:name, :arg1]
    #   [:name, [:arg1, :arg2]]
    #   [{:name => :dep1}]
    #   [{:name => [:dep1, :dep2]}]
    #   [:name, {:arg1 => :dep1}]
    #   [:name, {[:arg1, :arg2] => :dep1}]
    #   [:name, {:arg1 => [:dep1, :dep2]}]
    #   [:name, {[:arg1, :arg2] => [:dep1, :dep2]}]
    #   ... plus roles
    task_name = args.first.is_a?(Hash) ? args.first.keys.first : args.first
    host_task(task_name, {}, &block)
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
    # Placeholder for the `run` command in host_task blocks that will be passed directly to Weave.
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
