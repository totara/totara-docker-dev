# Contribute

If you want to contribute to this project please read the following instructions.

## Issues and Pull Requests

We try to collect all improvements and bug reports as Issues. Also we avoid pushing up changes directly into our branches by using Pull Requests for new features and bugfixes.

## Workflow

If you want to add a new feature or fix a bug:

1. Fork the repository
2. Check out the latest **master** branch - `git checkout master && git pull` 
3. Create a new feature or bugfix branch, for example: `git checkout -b feat-add-postgres18` (prefix with **feat**- or **fix**- and name it with something meaningful)
4. Create commits with a [conventional commit message](https://www.conventionalcommits.org), for example: "feat: Add Postgres 18 container" or "fix: Remove usage of deprecated PHP constant"
5. Push your commits into your own repository
6. Create a new Pull Request for your branch pointing to **master**.

When the pull request has been approved and merged, then a release will automatically be made,
using [semantic versioning](https://semver.org/) based upon the conventional commit messages in the merged pull request.
This will rebuild and push new versions of the containers.

If you have any questions don't hesitate to ask.
