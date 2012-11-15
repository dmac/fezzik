require "rake/testtask"

task :test => ["test:integrations"]

namespace :test do
  Rake::TestTask.new(:integrations) do |task|
    task.libs << "test"
    task.test_files = FileList["test/integration/**/*_test.rb"]
  end
end

desc "remove built gems"
task :clean do
  sh "rm fezzik-*" rescue true
end

desc "build gem"
task :build do
  sh "gem build fezzik.gemspec"
end

desc "install gem"
task :install => [:clean, :build] do
  sh "gem install `ls fezzik-*`"
end
