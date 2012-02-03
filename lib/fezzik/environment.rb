# TODO: Support per-server environments
module Fezzik
  def self.env(key, value)
    @environment ||= {}
    @environment[key] = value
  end

  def self.environment
    @environment ||= {}
  end
end
