module Fezzik
  module Util
    def self.capture_output(&block)
      output = StringIO.new
      $stdout = output
      block.call
      return output.string
    ensure
      $stdout = STDOUT
    end

    def self.split_task_and_params(task_with_params)
      params_match = /(.+)\[(.+)\]/.match(task_with_params)
      if params_match
        task = params_match[1]
        params = params_match[2].split(",")
      else
        task = task_with_params
        params = nil
      end
      [task, params]
    end

    # Blocks passed to this function will ensure `domain` is always an Array. In addition, if `user` is set it
    # will automatically prepend the value of `user` to the front of any domains missing a username. This allows a
    # fezzik user to write the following in their configuration and have it "just work":
    #     set :domain, ["example.com", "test@example2.com"]
    #     set :user, "root"
    # `domain` will be equal to ["root@example.com", "test@example2.com"]
    def self.with_prepended_user(&block)
      old_domain = domain
      begin
        set :domain, Array(domain).map { |d| (defined?(user) && !d.include?("@")) ? "#{user}@#{d}" : d }
        block.call
      ensure
        set :domain, old_domain
      end
    end
  end
end
