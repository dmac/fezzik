module Fezzik
  class HostTask < Rake::Task
    attr_accessor :roles, :weave_options

    def initialize(task_name, app)
      super
      @host_actions = []
      @roles = []
      @weave_options = {}
    end

    def enhance(deps = nil, &block)
      @host_actions << block if block_given?
      super(deps)
    end

    def execute(args = nil)
      return if Rake.application.options.dryrun

      if @roles.empty?
        hosts = Fezzik.get(:domain).map { |domain| "#{Fezzik.get(:user)}@#{domain}" }
        @@connection_pool ||= Weave::ConnectionPool.new
        @host_actions.each do |action|
          begin
            @@connection_pool.execute_with(hosts, @weave_options.merge(:args => [self, args]), &action)
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
            @@role_connection_pools[role] ||= Weave::ConnectionPool.new
            @host_actions.each do |action|
              begin
                @@role_connection_pools[role].execute_with(hosts, @weave_options.merge(:args => [self, args]),
                                                           &action)
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
