Gem::Specification.new do |s|
  s.name = "fezzik"
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">=0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 2 if s.respond_to? :specification_version=

  s.author = "Daniel MacDougall"
  s.email = "dmacdougall@gmail.com"

  s.description = "A light deployment system that gets out of your way"
  s.summary = "A light deployment system that gets out of your way"
  s.homepage = "http://github.com/dmacdougall/fezzik"
  s.rubyforge_project = "fezzik"

  s.executables = %w(fez fezify)
  s.files = %w(
    README.md
    TODO.md
    fezzik.gemspec
    lib/fezzik.rb
    bin/fez
    bin/fezify
  )
  s.add_dependency("rake", "~>0.8.7")
  s.add_dependency("rake-remote_task", "~>2.0.2")
  s.add_dependency("colorize", ">=0.5.8")
end
