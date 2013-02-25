module Fezzik
  module Util
    def self.capture_output(&block)
      output = StringIO.new
      Thread.current[:stdout] = output
      block.call
      output.string
    ensure
      Thread.current[:stdout] = STDOUT
    end
  end
end
