# Synchronize 'puts' because it's annoying to have interleaved output when rake remote task is running
# several things at once in multiple threads (for instance: commands on multiple servers or commands as
# multiple users).
#
# TODO(dmac): Is this made obsolete by thread_local_io.rb?
class IO
  @@print_mutex = Mutex.new
  alias :old_puts :puts
  def puts(*args) @@print_mutex.synchronize { old_puts(*args) } end
end

