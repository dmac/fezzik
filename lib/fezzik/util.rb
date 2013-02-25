module Fezzik
  module Util
    def self.capture_output(&block)
      warn "WARN [Fezzik]: Fezzik::Util.capture_output is deprecated as of 0.8.0," +
           " use `run \"...\", :output => capture` instead"
      output = StringIO.new
      $stdout = output
      block.call
      output.string
    ensure
      $stdout = STDOUT
    end
  end
end
