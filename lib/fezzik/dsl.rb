module Fezzik
  module DSL
    def destination(name, &block)
      Fezzik.destination(name, &block)
    end

    def env(*args)
      Fezzik.env(*args)
    end

    def capture_output(*args)
      Fezzik::Util.capture_output(*args)
    end
  end
end
