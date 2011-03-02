# Fezzik

Fezzik (or fez) is a slim and snappy alternative to Capistrano.

It sets up a rake-based rsync workflow with a single configuration file
and gets out of your way.

## Install

Put fezzik somewhere on your file system, then add <code>bin</code> to your path
or symlink to <code>fez</code> and <code>fezify</code>.

## Setup
    $ cd myproject
    $ ls
          server.rb
    $ fezify
          creating config/fezzik.rb
          creating config/deploy.rb
          creating bin/run_myproject.sh


**config/deploy.rb**: set your app name and destination servers
    set :app, "fezzik"
    ...
    destination :prod do
      set :domain, "www.fezzik.com"
    end

**bin/run_app.sh**: write a command that will start your app
    #!/bin/sh
    nohup ruby server.rb &

Ready to deploy!
    $ fez to_prod deploy
      ...
      fezzik deployed!
