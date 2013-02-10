## TODO for weave version

* Weave: Implement `target_host`.
* Figure out how to deprecate `rsync`

## Open Questions

* Should we keep or deprecate the behavior of adding settings to the global namespace?
* Should we include the "user@" portion of `target_host` or leave it off?
* Should an error in a host_task block halt execution of that task or continue?
