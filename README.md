# Fezzik

Fezzik (or fez) is a slim and snappy way to run commands on servers.
This is useful for many tasks, including deployment.

It wraps a rake-based rsync workflow and tries to keep things simple.

If upgrading to 0.8 from an earlier version of Fezzik, see [Upgrading](#upgrading).

## Install

```
gem install fezzik
```

## Basic setup

Require Fezzik in your project Rakefile and define a destination:

```ruby
require "fezzik"
include Fezzik::DSL

destination :prod do
  set :user, "root"
  set :domain, "myapp.com"
end
```

A host task is similar to a normal Rake task, but will run once for every host defined by `:domain`. The body
of a host task exposes two methods:

```
run <command> Run a shell command on the remote host
host          The domain that the currently running host task is targeting
```

Write some host tasks that will execute on the specified destination:

```ruby
namespace :fezzik do
  host_task :echo do
    run "echo 'Running on #{host}'"
  end
end
```

Run your host tasks with fezzik by passing a destination and list of tasks to run:

```
$ fez prod echo
```

### host_task

The `host_task` method is similar to Rake's `task` in functionality, but has a slightly different API due to
its additional options. A host task is defined with a name and some (optional) options. The three primary ones
are `:args`, `:deps`, and `:roles`. `:args` and `:deps` correspond to Rake's task arguments and task
dependencies, and `:roles` is a Fezzik-specific option explained later. There are also three additional
options which can be passed to [Weave](https://github.com/cespare/weave), Fezzik's underlying ssh library, by
specifying them in a `:weave_options` hash. They control how host tasks run concurrently:

- `:num_threads`: The number of threads used to run this task in parallel, or `:unlimited` to use a thread for
                  every host. Defaults to 10.
- `:serial`: Whether to process the command for each connection one at a time. Defaults to false.
- `:batch_by`: If set, group the connections into batches of no more than this value.

A Rake task that looks like this:

```ruby
task :echo, [:arg1, :arg2] => [:dep1, :dep2] do |t, args|
  ...
end
```

would look like this as a host task:

```ruby
host_task :echo, :args => [:arg1, :arg2],
                 :deps => [:dep1, :dep2] do |t, args|
  ...
end
```

And with Weave options:

```ruby
host_task :echo, :args => [:arg1, :arg2],
                 :deps => [:dep1, :dep2],
                 :weave_options => {:num_threads => 20} do |t, args|
  ...
end
```

To avoid repeating the same `weave_options` on every host_task, set `Fezzik.default_weave_options`, which
will be merged with the `:weave_options` hash of a `host_task`.

```ruby
Fezzik.default_weave_options = { :num_threads => :unlimited }
```

## Deployments

One of the more useful things you can use Fezzik for is handling deployments.

```ruby
require "fezzik"
include Fezzik::DSL

# Fezzik will automatically load any .rake files it finds in this directory.
Fezzik.init(:tasks => "config/tasks")

# The only special settings are `:domain` and `:user`. The rest are purely convention. All settings can be
# retrieved in your tasks with `get` (e.g., `get :current_path`).
set :app, "myapp"
set :user, "root"
set :deploy_to, "/opt/#{get :app}"
set :release_path, "#{get :deploy_to}/releases/#{Time.now.strftime("%Y%m%d%H%M")}"
set :current_path, "#{get :deploy_to}/current"

destination :staging do
  set :domain, "myapp-staging.com"
end

destination :prod do
  set :domain, "myapp.com"
end
```

Fezzik comes bundled with some useful tasks for common things like deployment.
You can download the ones you need:

```
$ cd config/tasks
$ fez get deploy
    [new] deploy.rake
```

You'll need to edit the `fezzik:start` and `fezzik:stop` tasks in deploy.rake since those are specific to your
project.

```ruby
namespace :fezzik do
  ...
  desc "runs the executable in project/bin"
  host_task :start do
    puts "starting from #{(run "readlink #{get :current_path}", :output => capture)[:stdout] }}"
    run "cd #{get :current_path} && ./bin/run_app.sh"
  end

  desc "kills the application by searching for the specified process name"
  Fezzik.host_task :stop do
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
[out|myapp.com] myapp deployed!
[success]
```

## Environments

Configuration often changes when you deploy your project. Fezzik lets you set environments for your hosts.

```
$ cd config/tasks
$ fez get deploy
    [new] deploy.rake
```

```ruby
destination :prod do
  set :domain, "myapp.com"
  env :rack_env, "production"
end
```

This will be exposed in the form of an environment.sh file and an environment.rb file in your project root
directory when you deploy. You can source the .sh file before running your app or require the .rb file in your
project directly.

```ruby
  desc "runs the executable in project/bin"
  host_task :start do
    run "cd #{get :current_path} && (source environment.sh || true) && ./bin/run_app.sh"
  end
```

You can assign different environments to subsets of hosts:

```ruby
destination :prod do
  set :domain, ["myapp1.com", "myapp2.com"]
  env :rack_env, "production"
  env :is_canary, "true", :hosts => ["myapp1.com"]
end
```

Fezzik accepts multiple destinations in the call to `destination`.
This can be useful if you have common environment variables shared across destinations.

```ruby
destination :staging, :prod do
  env :unicorn_workers, 4
end
```

You can access the environment settings in your tasks, if you like. It's a hash.

```ruby
task :inspect_all_environments do
  puts Fezzik.environments.inspect
end
```

To access the environment for the currently targeted host:

```ruby
host_task :inspect_environment do
  puts Fezzik.environments[host].inspect
end
```


## Roles

Fezzik supports role deployments. Roles allow you to assign host tasks different configurations according
to their purpose. For example, you might want to perform your initial package installations as root, but run
your app as an unprivileged user.

```ruby
destination :prod do
  set :domain, "myapp.com"
  role :root_user, :user => "root"
  role :run_user, :user => "app"
end

host_task :install, :roles => :root_user
  # Install all the things.
end

host_task :run, :roles => :run_user
  # Run all the things.
end
```

Or, you might have different domains for database deployment and app deployment.

```ruby
destination :prod do
  set :user, "root"
  role :db, :domain => "db.myapp.com"
  role :app, :domain => "myapp.com"
end
```

Roles in destination blocks can override global role settings.

```ruby
role :app, :domain => "localhost"

destination :prod do
  role :app, :domain => "myapp.com"
end
```

The `role` method accepts a role name and a hash of values that you want assigned with the
`set :var, value` syntax. These will override the global or destination settings when a host task is
run.


## Utilities

Fezzik exposes some functions that can be useful when running host tasks.

### Override hosts from command line

```
$ domain="example1.com,example2.com" fez prod deploy
```

Set the "domain" environment variable to override the domains set in your destination block. Useful for running
one-off tasks against a subset of your hosts.

### Capture or modify output

The output of `run` can be captured or modified instead of printing directly with the host prefix.

It can return a hash of `:stdout, :stderr`, or it can stream the raw output without prefixing each host.

```ruby
# prints "[out|myapp.com] hi"
run "echo 'hi'"

# prints "hi"
run "echo 'hi'", :output => :raw

# output == { :stdout => "hi" :stderr => "" }
output = run "echo 'hi'", :output => :capture
```

### A note on `puts`

Ruby's `puts` is not thread-safe. In particular, running multiple `puts` in parallel can result in the
newlines being separated from the rest of the string.

As a helper, any `puts` used from within a host task will call an overridden thread-safe version of `puts`. If
`$stdout.puts` or `$stderr.puts` is used instead, the normal thread-unsafe method will be called.


## DSL

Fezzik comes with a DSL module that you can optionally include in the top level of your Rakefiles with
`include Fezzik::DSL`. It exposes the following functions:

```
destination
host_task
set
get
env
role
capture_output
```

If you don't want to include these functions in your top-level namespace they can all be called directly on
the Fezzik module, e.g., `Fezzik.destination`.

## Included Tasks

Fezzik has a number of useful tasks other than those defined in deploy.rake. These can also be downloaded
with `$ fez get <task>` and placed in the directory you specify with `Fezzik.init(:tasks => "config/tasks")`.

These tasks are meant to be starting points. For example, if you want to save your environment files in a
place that's not your project root you can simply edit the task in deploy.rake.

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

Emergency! Rollback! Every deployment you make is saved on the server if you use the default tasks defined in
deploy.rake. You can move between these deployments (to roll back, for example), with rollback.rake.

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

### Rake passthroughs

Because Fezzik is built on Rake it passes through some options directly to Rake. You can use these with the
`fez` command as if you were running `rake` directly:

```
--trace    Turn on invoke/execute tracing, enable full backtrace.
--dry-run  Do a dry run without executing actions.
```

<a name="upgrading"></a>
## Upgrading

### 0.8.0

Fezzik 0.8 replaces much of its internal piping with [Weave](https://github.com/cespare/weave), an excellent
parallel SSH library. This allows for cleaner output and faster task execution due to using a shared
connection pool, but necessarily introduces a few breaking changes. These are detailed below.

### Breaking changes

- The method `target_host` is gone and has been replaced by using `host` in a host task. The old method `host`
  has been removed and there should no longer be a reason to use it.
- The `current_path` setting is no longer set automatically. To continue using it in your deployments, define
  it manually:

    ```ruby
    set :current_path, "#{get :deploy_to}/current`.
    ```

- The helper method `rsync` no longer exists. Instead of `rsync "..."` use `system("rsync -az ...")`
- The helper method `sudo` no longer exists. Instead of `sudo "..."` use `run "sudo ..."`

### Deprecations

- The `remote_task` method is deprecated. Use `host_task` instead.
- Using settings defined by `set` as top-level method calls is deprecated. For example, use
  `get :domain` instead of `domain`.
- Fezzik::Util.capture_output is deprecated. Pass options directly to `run` instead:

    ```ruby
    run "echo 'hi'", :output => :capture
    run "echo 'hi'", :output => :raw
    ```
