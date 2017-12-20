# Github Template Injector

Simple script that relies on having [personal access tokens](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
for your source and target.

## Getting Started

Really simple. Grab the script. Set the params. Run the script. Cleanup anything
that didn't push.

```bash
$ export GITHUB_AUTH_TOKEN=XXXXXX
$ export GITHUB_ORG=migrated-things
$ export GITHUB_URI=git.private.domain
$ bash gh-templater.sh
...
```