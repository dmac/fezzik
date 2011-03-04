desc "remove built gems"
task :clean do
  sh "rm fezzik-*"
end

desc "build gem"
task :build do
  sh "gem build fezzik.gemspec"
end

desc "install gem"
task :install => [:clean, :build] do
  sh "sudo gem install `ls fezzik-*`"
end

