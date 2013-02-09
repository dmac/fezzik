module Fezzik
  class HostTask < Rake::Task
    attr_accessor :roles

    def initialize(task_name, app)
      super
      @roles = []
    end

    # TODO: We probably will need to override this due to the block.
    def enhance(deps = nil, &block)
      super(deps)
    end

    def execute(args = nil)
      super(args)
      # TODO: When we add role functionality, check for domain setting and pass to pool.execute.
      hosts = fetch(:domain).map { |domain| "#{fetch(:user)}@#{domain}" }
      @@connection_pool ||= Weave.connect(hosts)
      @actions.each do |action|
        @@connection_pool.execute(&action)
      end
    end
  end
end
