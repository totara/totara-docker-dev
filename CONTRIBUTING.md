# Contribute

If you want to contribute to this project please read the following instructions.

## Issues and Pull Requests

We try to collect all improvements and bug reports as Issues. Also we avoid pushing up changes directly into our branches by using Pull Requests for new features and bugfixes.

## Workflow

We follow the [GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow).

## Standard workflow

If you want to add a new feature or fix a bug

1. Fork the repository
2. Check out the **develop** branch `git checkout develop` 
3. Create a new feature or bugfix branch `git checkout -b feature-upgrade-nodejes` (prefix with **feature**- or **bugfix**- and name it with something meaningful)
4. Create and push your commits into your own repository
5. Create a new Pull Request for your branch pointing to **develop**. Don't point it to **master** directly.

When enough features come together we will merge develop into master, create a new tag and publish it as a new release. With this approach the master will always contain the latest stable version.

## Hotfixes

If something critical needs to be fixed and released please 

1. Create a hotfix branch (prefix with hotfix- and name it properly) based on the current master
2. Fix the code
3. Create a new Pull Request from your hotfix branch pointing it to **master**
4. Once it got reviewed and merged we will merge master back into develop to make sure it's in sync.

## Unstable releases

We might release unstable versions. Those will be tagged on develop and released clearly marked as unstable releases.

If you have any questions don't hesitate to ask.