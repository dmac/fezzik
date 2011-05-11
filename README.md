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
