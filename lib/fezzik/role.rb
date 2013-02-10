module Fezzik
  def self.role(role_name, settings)
    @roles ||= {}
    @roles[role_name] = settings
  end

  def self.roles() @roles ||= {} end

  # TODO: Consider allowing roles that don't override an existing setting.
  # Right now you have to do: set :foo nil; role :foo_role {:foo => :bar}
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
    settings.each { |setting, value| Fezzik.set setting, value }
  end
end
