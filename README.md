# Fezzik

Fezzik (or fez) is a slim and snappy alternative to Capistrano.

It sets up a rake-based rsync workflow with a single configuration file
and gets out of your way.

## Install

    sudo gem install fezzik

## Setup

    $ cd myproject
    $ ls
          server.rb
    $ fezify
          [new] bin/run_app.sh created
          [new] config/recipes/core.rb created
          [new] config/deploy.rb created
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

    $ fez to_prod deploy
      ...
      fezzik deployed!

## Utilities

Fezzik exposes some utilities that can be useful when running remote tasks.

**capture\_output(&block)**

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
found in the fezzik project recipes directory. If you write a general recipe that would be useful to other
developers, please submit a pull request!
