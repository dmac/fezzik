# Fezzik

Fezzik (or fez) is a slim and snappy way to run commands on servers.
This is useful for many tasks, including deployment.

It wraps a rake-based rsync workflow and tries to keep things simple.

## Install

    gem install fezzik

## Basic setup

Require Fezzik in your project Rakefile and define a destination:

```ruby
require "fezzik"

Fezzik.destination :prod do
  set :user, "root"
  set :domain, "myapp.com"
end
```

Write some rake tasks that will execute on the specified destination:

```ruby
namespace :fezzik do
  remote_task :touch do
    run "touch /tmp/test_file"
  end
end
```

Run your remote_tasks with fezzik:

```
$ fez prod touch
```

## Deployments

One of the more useful things you can use Fezzik for is handling deployments.

```ruby
require "fezzik"

# Fezzik will automatically load any .rake files it finds in this directory.
Fezzik.init(:tasks => "config/tasks")

# Fezzik wraps rake/remote_task, which is the same rake plugin used by Vlad the Deployer.
# See http://hitsquad.rubyforge.org/vlad/doco/variables_txt.html for a full list of variables it supports.

set :app, "myapp"
set :deploy_to, "/opt/#{app}"
set :release_path, "#{deploy_to}/releases/#{Time.now.strftime("%Y%m%d%H%M")}"
set :local_path, Dir.pwd
set :user, "root"

Fezzik.destination :staging do
  set :domain, "myapp-staging.com"
end

Fezzik.destination :prod do
  set :domain, "myapp.com"
end
```

Fezzik comes bundled with some useful rake tasks for common things like deployment.
You can download the ones you need:

```
$ cd config/tasks
$ fez get deploy
    [new] deploy.rake
```

You'll need to edit the fezzik:start and fezzik:stop tasks in deploy.rake since those are specific to your
project.

```ruby
namespace :fezzik do
  ...
  desc "runs the executable in project/bin"
  remote_task :start do
    puts "starting from #{Fezzik::Util.capture_output { run "readlink #{current_path}" }}"
    run "cd #{current_path} && ./bin/run_app.sh"
  end

  desc "kills the application by searching for the specified process name"
  remote_task :stop do
    puts "stopping app"
    run "(kill `ps aux | grep 'myapp' | grep -v grep | awk '{print $2}'` || true)"
  end
  ...
end
```

Deploy win!

```
$ fez prod deploy
...
myapp deployed!
[success]
```

## Environments

Configuration often changes when you deploy your project. Fezzik lets you set environments for your hosts.

```
$ cd config/tasks
$ fez get environment
    [new] environment.rake
```

```ruby
Fezzik.destination :prod do
  set :domain, "myapp.com"
  Fezzik.env :rack_env, "production"
end
```

This will be exposed in the form of an environment.sh file and an environment.rb file in your project root
directory when you deploy. You can source the .sh file before running your app or require the .rb file in your
project directly.

```ruby
  desc "runs the executable in project/bin"
  remote_task :start do
    puts "starting from #{Fezzik::Util.capture_output { run "readlink #{current_path}" }}"
    run "cd #{current_path} && (source environment.sh || true) && ./bin/run_app.sh"
  end
```

You can assign different environments to a subset of the hosts you deploy to.

```ruby
Fezzik.destination :prod do
  set :domain, ["myapp1.com", "myapp2.com"]
  Fezzik.env :rack_env, "production"
  Fezzik.env :is_canary, "true", :hosts => ["myapp1.com"]
end
```

Fezzik accepts multiple destinations in the call to `Fezzik.destination`.
This can be useful if you have common environment variables shared across destinations.

```ruby
Fezzik.destination :staging, :prod do
  env :unicorn_workers, 4
end
```

You can access the environment settings in your tasks, if you like. It's a hash.

```ruby
task :inspect_environment do
  puts Fezzik.environments.inspect
end
```


## Roles

Fezzik supports role deployments. Roles allow you to assign remote_tasks different configurations according
to their purpose. For example, you might want to perform your initial package installations as root, but run
your app as an unprivileged user.

```ruby
Fezzik.destination :prod do
  set :domain, "myapp.com"
  Fezzik.role :root_user, :user => "root"
  Fezzik.role :run_user, :user => "app"
end

remote_task :install, :roles => :root_user
  # Install all the things.
end

remote_task :run, :roles => :run_user
  # Run all the things.
end
```

Or, you might have different domains for database deployment and app deployment.

```ruby
Fezzik.destination :prod do
  set :user, "root"
  Fezzik.role :db, :domain => "db.myapp.com"
  Fezzik.role :app, :domain => "myapp.com"
end
```

Roles in destination blocks can override global role settings.

```ruby
Fezzik.role :app, :domain => "localhost"

Fezzik.destination :prod do
  Fezzik.role :app, :domain => "myapp.com"
end
```

The `Fezzik.role` method accepts a role name and a hash of values that you want assigned with the
`set :var, value` syntax. These will override the global or destination settings when that remote_task is
run.


## Utilities

Fezzik exposes some functions that can be useful when running remote tasks.

### Override hosts from command line

```
$ domain="example1.com,example2.com" fez prod deploy
```

Set the "domain" environment variable to override the domains set in your destination block. Useful for running
one-off tasks against a subset of your hosts.

### Capture or redirect output

```ruby
Fezzik::Util.capture_output(&block)
```

Use this function if you would like to hide or capture the normal output that the "run" command prints.

```ruby
remote_task :print_hello
  # Nothing is printed to stdout
  server_output = Fezzik::Util.capture_output { run "echo 'hello'"}

  # prints "hello"
  puts server_output
end
```

### Inspect the target destination

You can see which destination fezzik is operating on from within your tasks.

```ruby
task :print_destination
  puts Fezzik.target_destination
end
```


## DSL

Fezzik comes with a DSL module that you can optionally include in the top level of your Rakefiles. It exposes
the following functions:

```
destination
env
role
capture_output
```

This lets you write your configuration more tersely:

```ruby
include Fezzik::DSL

destination :prod do
  env :rack_env, "production"
  role :root_user, :user => "root"
end
```


## Tasks

Fezzik has a number of useful tasks other than deploy.rake and environment.rake. These can also be downloaded
with `$ fez get <task>` and placed in the directory you specify with `Fezzik.init(:tasks => "config/tasks")`.

These tasks are meant to be starting points. For example, if you want to save your environment files in a
place that's not your project root you can simply edit the task in environment.rake.

If you write a recipe that would be useful to other developers, please submit a pull request!

### Command

```
$ cd config/tasks
$ fez get command
    [new] command.rake
```

Sometimes you just need to get your hands dirty and run a shell on your servers.
The command.rake tasks give you a prompt that lets you execute shell code on each of your hosts.

```
$ fez prod command
Targeting hosts:
    root@myapp.com
run command (or "quit"): tail www/myapp/log.txt -n 1
[2011-07-01 00:01:23] GET / 200
```

You can also run a single command:

```
$ fez prod "command_execute[ls]"
```

### Rollback

```
$ cd config/tasks
$ fez get rollback
    [new] rollback.rake
```

Emergency! Rollback! Every deployment you make is saved on the server by default.
You can move between these deployments (to roll back, for example), with the rollback.rb recipe.

```
$ fez prod rollback
configuring for root@myapp.com
=== Releases ===
0: Abort
1: 201107051328 (current)
2: 201106231408
3: 201106231352
Rollback to release (0):
```

