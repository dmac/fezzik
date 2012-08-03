# A monkey-patch of Rake::RemoteTask code to run a remote task serially (one node at a time) if the
# :serial => true option is set.
class Rake::RemoteTask < Rake::Task
  class Action
    alias :parallel_execute :execute

    # Note: we limit the host by setting ENV["HOSTS"] here. That means that any tasks called from the serial task
    # using Rake::Task[task_name].invoke will only execute for that one host.
    # TODO: not sure what happens if a serial task has non-serial tasks as dependencies. Hopefully, nothing special -
    # the dependencies should run in parallel unless they also have the :serial => true option.
    def serial_execute hosts, task, args
      hosts.each do |host|
        task2 = task.clone
        task2.target_host = host
        saved_hosts_env = ENV["HOSTS"]
        begin
          ENV["HOSTS"] = host
          Thread.current[:task] = task2
          case block.arity
          when 1 then block.call task2
          else block.call task2, args
          end
          Thread.current[:task] = nil
        ensure
          ENV["HOSTS"] = saved_hosts_env
        end
      end
    end

    def execute hosts, task, args
      if task.options[:serial] == true
        serial_execute hosts, task, args
      else
        parallel_execute hosts, task, args
      end
    end
  end
end
