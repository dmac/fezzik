module Fezzik
  def self.env(key, value, options={})
    options = {
      :hosts => Fezzik.get(:domain)
    }.merge(options)
    options[:hosts] = Array(options[:hosts])
    @environments ||= Hash.new { |h, k| h[k] = {} }
    options[:hosts].each { |host| @environments[host][key] = value }
  end

  def self.environments
    @environments ||= Hash.new { |h, k| h[k] = {} }
  end
end
