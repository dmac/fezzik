# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fezzik/version"

Gem::Specification.new do |s|
  s.name = "fezzik"
  s.version = Fezzik::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">=0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 2 if s.respond_to? :specification_version=

  s.authors = ["Daniel MacDougall", "Caleb Spare"]
  s.email = "dmacdougall@gmail.com"

  s.description = "A light deployment system that gets out of your way"
  s.summary =<<EOS
Fezzik adds remote ssh capabilities to Rake. It simplifies running commands on remote servers and can be used
for anything from deploying code to installing libraries remotely.
EOS
  s.homepage = "http://github.com/dmacdougall/fezzik"
  s.rubyforge_project = "fezzik"

  s.executables = %w(fez)
  s.files = `git ls-files`.split("\n")

  s.add_dependency "rake"
  s.add_dependency "weave", "=0.1.0"

  s.add_development_dependency("scope", "~>0.2.3")
  s.add_development_dependency("vagrant", "~>1.0.5")
end
