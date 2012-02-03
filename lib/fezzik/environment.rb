# TODO: Write .rake file for saving per-server configs
module Fezzik
  def self.env(key, value, opts={})
    # TODO: Should be able to specify either domain.com or user@domain.com
    opts[:hosts] = Array(opts[:hosts])
    options = {
      :hosts => domain
    }.merge(opts)
    @environments ||= Hash.new { |h, k| h[k] = {} }
    options[:hosts].each { |host| @environments[host][key] = value }
  end

  def self.environments
    @environments ||= Hash.new { |h, k| h[k] = {} }
  end
end
