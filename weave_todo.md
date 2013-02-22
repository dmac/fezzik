## TODO

* Rewrite tasks in a weave-y fashion.

## Breaking changes in the weave branch

* `target_host` is gone
* `host` is now an alias for `target_host`, not a method
* `rsync` no longer exists (unless we write a new helper function)

## Other docs to write

* Call `warn` for deprecation notices
* document --trace and --dry-run passthrough flags
* puts is not thread-safe; instead, use print "" + "\n" (NOTE: Caleb -- this isn't actually true; the `puts`
  you get in a `remote_task` is a Weave wrapper, which is thread-safe. However, if you use `STDERR.puts` or
  `STDOUT.puts` or `print` or anything else, it's not going to be threadsafe. This may be worth pointing out
  in the docs.)
* capture_output captures the host prefix on each line. Instead pass :capture => :output to `run`.
  You can also use capture_output and pass :capture => raw
* We no longer provide `current_path`, which is a RRT-ism. However, this was kind of a convention anyway --
  RRT sets it to "current" and we generally leave that alone. In fact, if you look at the default deploy task
  (https://github.com/dmacdougall/fezzik/blob/master/tasks/deploy.rake) you'll see that we use `current_path`
  in some places and the string "current" in others. The new convention should just be `set :current_path,
  "#{get :deploy_to}/current"` and then use `current_path` as a normal setting.
