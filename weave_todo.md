## TODO for weave version

* Test with capture_output
* Test everything in ruby 1.8.7

## Open Questions

* Should we keep or deprecate the behavior of adding settings to the global namespace?

## Breaking changes in the weave branch

* `target_host` is gone
* `host` is now an alias for `target_host`, not a method
* `rsync` no longer exists (unless we write a new helper function)

## Other docs to write

* document --trace and --dry-run passthrough flags
* puts is not thread-safe; instead, use print "" + "\n"
