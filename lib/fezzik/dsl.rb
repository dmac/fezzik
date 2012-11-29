module Fezzik
  module DSL
    # This is necessary to override Rake::RemoteTask's globally eval'ed method definitions.
    def self.included(klass)
      klass.class_eval do
        def role(*args) Fezzik.role(*args) end
      end
    end
    def destination(*names, &block) Fezzik.destination(*names, &block) end
    def env(*args) Fezzik.env(*args) end
    def capture_output(&block) Fezzik::Util.capture_output(&block) end
  end
end
