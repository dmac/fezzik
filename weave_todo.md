## TODO for weave version

* Weave: Expose to Fezzik when one of the `run` commands fails
* Weave: Allow passing arguments to the host_task block
* Weave: Implement `target_host`.
* Confirm rake dry-run works; document it (useful feature for deployment)


## Open Questions

* Should we keep or deprecate the behavior of adding settings to the global namespace?
* Should we include the "user@" portion of `target_host` or leave it off?
* Should an error in a host_task block halt execution of that task or continue?
