module Fezzik
  module DSL
    def destination(*names, &block) Fezzik.destination(*names, &block) end
    def env(*args) Fezzik.env(*args) end
    def capture_output(&block) Fezzik::Util.capture_output(&block) end
    def set(name, value) Fezzik.set(name, value) end
    def get(name) Fezzik.get(name) end
    def remote_task(*args, &block) Fezzik.remote_task(*args, &block) end
    def host_task(name, options = {}, &block) Fezzik.host_task(name, options, &block) end
    def role(*args) Fezzik.role(*args) end
  end
end
