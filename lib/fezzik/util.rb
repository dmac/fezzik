module Fezzik
  def self.capture_output(&block)
    output = StringIO.new
    $stdout = output
    block.call
    return output.string
  ensure
    $stdout = STDOUT
  end
end
