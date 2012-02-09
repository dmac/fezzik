# Fezzik

Fezzik (or fez) is a slim and snappy way to run commands on servers.
This is useful for many things, including deployment.

It wraps a rake-based rsync workflow and tries to keep it simple.

**NOTE**: As of 2/8/12 this README is out of date. It will be updated shortly.

## Install

    gem install fezzik

## Setup

    $ cd myproject
    $ ls
          server.rb
    $ fezify
          [new]  bin/run_app.sh created
          [new]  config/recipes/core.rb created
          [new]  config/deploy.rb created
          [done]

**config/deploy.rb**: set your app name and destination servers

    set :app, "fezzik"
    ...
    destination :prod do
      set :domain, "www.fezzik.com"
    end

**bin/run_app.sh**: write a command that will start your app

    #!/bin/sh
    nohup ruby server.rb > /dev/null 2>&1 &

Ready to deploy!

    $ fez prod deploy
      ...
      fezzik deployed!

## Utilities

Fezzik exposes some utilities that can be useful when running remote tasks.

### Host override

Sometimes you'll want to run a fezzik task on a subset of hosts, rather than the full destination fleet.
You can override what hosts a fezzik task executes on from the command line.

    # deploy to a single host
    $ fez prod:domain1.com deploy

    # deploy to a single host as root
    $ fez prod:root@domain1.com deploy

    # deploy to multiple hosts
    $ fez prod:domain1.com,domain2.com deploy

The overriding hosts don't need to be a subset of the specified destination's domains.
They can be any hosts you want to use with a destination's configuration.

### Capture or redirect output

    capture_output(&block)

Use this function if you would like to hide or capture the normal output that the "run" command prints.

    remote_task :my_task
      # Nothing is printed to stdout
      server_output = capture_output { run "echo 'hello'"}

      # prints "hello"
      puts server_output
    end

## Recipes

Fezzik uses a recipe system similar to Capistrano. Any recipe placed in your config/recipes directory will be
picked up and available to the fez command. Some useful recipes that are not part of the fezzik core can be
found in the fezzik project recipes directory. You can download them with fezzik:

    fez get <recipes>

If you write a recipe that would be useful to other developers, please submit a pull request!

### Command

    fez get command

Sometimes you just need to get your hands dirty and run a shell on your servers.
The command.rb recipe gives you a prompt that lets you execute shell code on each of your hosts.

    $ fez prod command
    configuring for root@domain.com
    run command (or "quit"): tail www/myapp/log.txt -n 1
    [2011-07-01 00:01:23] GET / 200

You can also run a single command:

    $ fez prod command_execute\['ls'\]

(You'll probably need to escape the `[]` in your shell as well.)

### Rollback

    fez get rollback

Emergency! Rollback! Every deployment you make is saved on the server by default.
You can move between these deployments (to roll back, for example), with the rollback.rb recipe.

    $ fez prod rollback
    configuring for root@domain.com
    === Releases ===
    0: Abort
    1: 201107051328 (current)
    2: 201106231408
    3: 201106231352
    Rollback to release (0):

