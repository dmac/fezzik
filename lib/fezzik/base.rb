module Fezzik
  def self.activated=(value) @activated = value end
  def self.activated?() @activated || false end

  def self.default_weave_options() @@default_weave_options ||= {} end
  def self.default_weave_options=(options) @@default_weave_options = options end

  def self.set(name, value)
    @@settings ||= {}

    value = Array(value) if name == :domain

    @@settings[name] = value

    if Object.public_instance_methods.include? name.to_sym
      Object.send :alias_method, :"old_#{name}", name
    end

    Object.send :define_method, name do
      warn "WARN [Fezzik]: accessing #{name} at the top-level is deprecated as of 0.8.0," +
           " use Fezzik.get(:#{name}) instead"
      Fezzik.get name
    end
  end

  def self.get(name)
    raise "Fezzik: No such setting: #{name}" unless @@settings.has_key?(name)
    @@settings[name]
  end

  def self.clear(name) @@settings.delete(name) end

  def self.remote_task(*args, &block)
    warn "WARN [Fezzik]: remote_task is deprecated as of 0.8.0, use host_task instead"
    roles = (Hash === args.last && args.last[:roles]) ? args.pop[:roles] : []
    name, args, deps = Rake.application.resolve_args(args)
    host_task(name, { :args => Array(args), :deps => Array(deps), :roles => Array(roles) }, &block)
  end

  def self.host_task(name, options = {}, &block)
    options = {
      :args => [],
      :deps => [],
      :roles => [],
      :weave_options => {}
    }.merge(options)
    weave_options = options[:weave_options]
    options.delete(:weave_options)
    options.each { |key, value| options[key] = Array(value) }
    t = HostTask.define_task(name, { options[:args] => options[:deps] }, &block)
    t.roles += options[:roles]
    t.weave_options = t.weave_options.merge(weave_options)
  end

  def self.init(options={})
    @options = options
    @target_destination = ENV["fezzik_destination"].to_sym rescue nil
    unless options[:tasks].nil?
      $stderr.puts "Loading Fezzik tasks from #{@options[:tasks]}"
      Dir[File.join(File.expand_path(@options[:tasks]), "**", "*.rake")].sort.each do |lib|
        Rake.application.add_import(lib)
      end
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
