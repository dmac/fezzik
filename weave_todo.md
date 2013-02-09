## TODO for weave version

* Implement `HostTask`
* Implement `host_task`
* Implement `target_host`. May requre addition to Weave.
* Integrate roles with `HostTasks`s
* Confirm rake dry-run works; document it (useful feature for deployment)


## Open Questions

* Should we keep or deprecate the behavior of adding settings to the global namespace?
* Should we include the "user@" portion of `target_host` or leave it off?
* Should an error in a host_task block halt execution of that task or continue?
