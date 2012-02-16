module Fezzik
  module DSL
    def destination(name, &block)
      Fezzik.destination(name, &block)
    end

    def env(*args)
      Fezzik.env(*args)
    end

    def capture_output(&block)
      Fezzik::Util.capture_output(&block)
    end
  end
end
