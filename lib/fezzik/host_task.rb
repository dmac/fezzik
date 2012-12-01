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
    end
  end
end
