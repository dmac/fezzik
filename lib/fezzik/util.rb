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
  end
end
