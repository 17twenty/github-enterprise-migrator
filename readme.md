# Github Enterprise Migrator

*Warning: This is not the official GH-migrator - I didn't want to login to
remote boxes to mess with stuff so that one was out.*

Simple script that relies on having [personal access tokens](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
for your source and target.

## Getting Started

Really simple. Grab the script. Set the params. Run the script. Cleanup anything
that didn't push.

```bash
$ export GITHUB_PRIVATE_AUTH_TOKEN=XXXXXX
$ export GITHUB_ENTERPRISE_TOKEN=XXXXXX
$ export GITHUB_PRIVATE_ORG=companyName
$ export GITHUB_ENTERPRISE_ORG=migrated-things
$ export GITHUB_ENTERPRISE_URI=git.private.domain
$  bash migrator.sh

Migrator will dupe all your Github Repos into your Github Enterprise account
It uses the private user tokens with admin:* required for both accounts
It will start in 5 seconds (CTRL-C to cancel)...
...
```