module Fezzik
  def self.role(role_name, settings)
    @roles ||= {}
    @roles[role_name] = settings
  end

  def self.roles() @roles ||= {} end

  def self.with_role(role_name, &block)
    return block.call if roles[role_name].nil?

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
end

module Rake
  class RemoteTask
    def defined_target_hosts?() true end
    def target_hosts() domain end

    alias remote_task_execute execute
    def execute(args = nil)
      return Fezzik::Util.with_prepended_user { remote_task_execute(args) } if options[:roles].empty?
      options[:roles].each do |role|
        Fezzik.with_role(role) { Fezzik::Util.with_prepended_user { remote_task_execute(args) } }
      end
    end
  end
end
