namespace :fezzik do
  desc "interactively run commands on destination servers"
  remote_task :command do
    while (true) do
      print "run command (or \"quit\"): "
      STDOUT.flush
      command = STDIN.gets.chomp
      if command.downcase == "quit"
        break
      else
        begin
          run "#{command}"
        rescue Exception
        end
      end
    end
  end
end
