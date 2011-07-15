#
# A recipe for running commands on destination hosts.
#
# Tasks:
#  * command: interactively run commands on destination servers
#  * command_execute: run a single command on destination servers
#
namespace :fezzik do
  desc "interactively run commands on destination servers"
  task :command do
    target_domain = domain.is_a?(Array) ? domain.first : domain
    while (true) do
      print "run command (or \"quit\"): "
      STDOUT.flush
      command = STDIN.gets.chomp
      if command.downcase == "quit"
        break
      else
        begin
          Rake::Task["fezzik:command_execute"].invoke command
        rescue Exception
        end
      end
    end
  end

  desc "run a single command on destination servers"
  remote_task :command_execute, :command do |t, args|
    run args[:command]
  end
end
