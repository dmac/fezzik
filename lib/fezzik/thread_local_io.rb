# Overrides $stdout and allows it to be overridden by the thread-local variable Thread.current[:stdout].
#
# If Thread.current[:stdout] is set, the thread will write all output there. Otherwise the thread will
# use $stdout as normal.
#
# Example usage:
#
# out = StringIO.new
#
# Thread.start do
#   Thread.current[:stdout] = out
#   puts "thread1"
# end.join
#
# Thread.start do
#   puts "thread2"
# end.join
#
# puts out.string
#
# Output:
#   thread2
#   thread1

module Fezzik
  class ThreadLocalIO < IO
    @@former_stdout = $stdout

    def self.write(*args)
      if Thread.current[:stdout]
        Thread.current[:stdout].write(*args)
      else
        @@former_stdout.write(*args)
      end
    end

    def self.flush
      if Thread.current[:stdout]
        Thread.current[:stdout].flush
      else
        @@former_stdout.flush
      end
    end
  end
end

$stdout = Fezzik::ThreadLocalIO
