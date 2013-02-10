## Breaking changes in the weave branch

* `target_host` is gone
* `host` is now an alias for `target_host`, not a method
* `rsync` no longer exists (unless we write a new helper function)

## Other docs to write

* Call `warn` for deprecation notices
* document --trace and --dry-run passthrough flags
* puts is not thread-safe; instead, use print "" + "\n"
* capture_output captures the host prefix on each line. Instead pass :capture => :output to `run`.
  You can also use capture_output and pass :capture => raw
