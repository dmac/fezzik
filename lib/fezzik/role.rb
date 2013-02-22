module Fezzik
  def self.role(role_name, settings)
    @roles ||= {}
    @roles[role_name] = settings
  end

  def self.roles() @roles ||= {} end

  def self.with_role(role_name, &block)
    return block.call if roles[role_name].nil?

    overridden_settings = {}
    new_settings = []
    roles[role_name].each_key do |name|
      if @@settings.has_key? name
        overridden_settings[name] = Fezzik.get(name)
      else
        new_settings << name
      end
    end
    override_settings(roles[role_name])
    begin
      block.call
    ensure
      override_settings(overridden_settings, new_settings)
    end
  end

  def self.override_settings(to_set, to_clear = [])
    to_clear.each { |setting| Fezzik.clear setting }
    to_set.each { |setting, value| Fezzik.set setting, value }
  end
end
