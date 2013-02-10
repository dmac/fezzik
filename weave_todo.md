## TODO for weave version

* Weave: Implement `target_host`.
* Figure out how to deprecate `rsync`
* Test everything in ruby 1.8.7

## Open Questions

* Should we keep or deprecate the behavior of adding settings to the global namespace?

## Breaking changes in the weave branch

* `target_host` no longer includes "user@", it's just the domain
* `rsync` no longer exists (unless we write a new helper function)
* `host` is now an alias for `target_host`, not a method
