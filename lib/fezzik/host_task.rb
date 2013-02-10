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

      # TODO(weave): Call action with args (requires weave addition?)
      if @roles.empty?
        hosts = Fezzik.get(:domain).map { |domain| "#{Fezzik.get(:user)}@#{domain}" }
        @@connection_pool ||= Weave.connect(hosts)
        @host_actions.each do |action|
          begin
            @@connection_pool.execute(:args => [self, args], &action)
          rescue Weave::Error => e
            STDERR.puts "Error running command in HostTask '#{@name}':"
            abort e.message
          end
        end
      else
        @roles.each do |role|
          Fezzik.with_role(role) do
            hosts = Fezzik.get(:domain).map { |domain| "#{Fezzik.get(:user)}@#{domain}" }
            @@role_connection_pools ||= {}
            @@role_connection_pools[role] ||= Weave.connect(hosts)
            @host_actions.each do |action|
              begin
                @@role_connection_pools[role].execute(:args => [self, args], &action)
              rescue Weave::Error => e
                STDERR.puts "Error running command in HostTask '#{@name}' with role '#{role}':"
                abort e.message
              end
            end
          end
        end
      end
    end
  end
end
