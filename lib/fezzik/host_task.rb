module Fezzik
  class HostTask < Rake::Task
    attr_accessor :roles

    def initialize(task_name, app)
      super
      @roles = []
      @host_actions = []
    end

    # We override `enhance` rather than calling super because we don't want the host_task block passed to the
    # superclass.
    alias_method :original_enhance, :enhance
    def enhance(deps = nil, &block)
      original_enhance(deps)
      @host_actions << block if block_given?
      self
    end

    def execute(args = nil)
      super(args)
      # TODO: When we add role functionality, check for domain setting and pass to pool.execute.
      hosts = fetch(:domain).map { |domain| "#{fetch(:user)}@#{domain}" }
      @@connection_pool ||= Weave.connect(hosts)
      @host_actions.each do |action|
        @@connection_pool.execute(&action)
      end
    end
  end
end
