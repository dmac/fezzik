module Fezzik
  def self.role(role_name, settings)
    @roles ||= {}
    @roles[role_name] = settings
  end

  def self.roles() @roles ||= {} end

  def self.with_role(role_name, &block)
    if roles[role_name].nil?
      block.call
      return
    end

    old_settings = Hash[roles[role_name].map { |setting, value| [setting, self.send(setting)] }]
    override_settings(roles[role_name])
    begin
      block.call
    ensure
      override_settings(old_settings)
    end
  end

  def self.override_settings(settings)
    settings.each { |setting, value| self.send(:set, setting, value) }
  end

  def self.task_roles() @task_roles ||= {} end

  def self.remote_task(*args, &block)
    @task_roles ||= {}
    if args.last.is_a?(Hash) && args.last.has_key?(:roles)
      task_name = args[0].is_a?(Hash) ? args[0].keys.first : args[0]
      @task_roles[task_name] = Array(args.last[:roles])
      args.last[:roles] = nil
    end
    Rake::RemoteTask.remote_task(*args, &block)
  end
end
