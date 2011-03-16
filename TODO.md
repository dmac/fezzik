## Features
* rollback
* rolling restarts
* parallel execution
* clear old releases
* better way to update recipes/core with gem updates
* figure out how to include/share common recipes
* per-server or per-group configurations

## Bugs
* symlink task links to a nonexistant directory when run in isolation

## Release Notes
* copy previous deployment to destination before rsync (for faster rsync)
* copy unsafe links with rsync (done with -L)
