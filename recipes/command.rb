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
    loop do
      print "run command (or \"quit\"): "
      STDOUT.flush
      command = STDIN.gets.chomp
      next if command.empty?
      if ["quit", "q", "exit"].include? command.downcase
        break
      else
        begin
          Rake::Task["fezzik:command_execute"].invoke command
        rescue Rake::CommandFailedError
        ensure
          Rake::Task["fezzik:command_execute"].reenable
        end
      end
    end
  end

  desc "run a single command on destination servers"
  remote_task(:command_execute, :command) { |t, args| run args[:command] }
end
