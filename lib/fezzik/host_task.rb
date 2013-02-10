module Fezzik
  class HostTask < Rake::Task
    attr_accessor :roles

    def initialize(task_name, app)
      super
      @roles = []
      @host_actions = []
    end

    def enhance(deps = nil, &block)
      @host_actions << block if block_given?
      super(deps)
    end

    def execute(args = nil)
      return if Rake.application.options.dryrun

      # TODO(weave): Handle failure of a call to `run`. Throw a Fezzik::CommandFailedError.
      # TODO(weave): Call action with args (requires weave addition?)
      if @roles.empty?
        hosts = Fezzik.get(:domain).map { |domain| "#{Fezzik.get(:user)}@#{domain}" }
        @@connection_pool ||= Weave.connect(hosts)
        @host_actions.each { |action| @@connection_pool.execute(&action) }
      else
        @roles.each do |role|
          Fezzik.with_role(role) do
            hosts = Fezzik.get(:domain).map { |domain| "#{Fezzik.get(:user)}@#{domain}" }
            role_connection_pool = Weave.connect(hosts)
            @host_actions.each { |action| role_connection_pool.execute(&action) }
          end
        end
      end
    end
  end
end
