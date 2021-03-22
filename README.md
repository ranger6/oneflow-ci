# release version management

This branch is separate from the main repo (code + ci). It
contains:

1. A `version` file used by the Concourse semver resource.
2. A `release-manifest` file used to both trigger and configure new releases. The CI release pipeline is triggered on a change to this file. The file is loaded by Concourse to set variables.

This branch was created with the following git commands:

```
git checkout --orphan version
git rm --cached -r .
rm -rf *
rm .gitignore .gitmodules
touch README.md
git add .
git commit -m "new branch version and release manifest branch"
git push origin version
```

## `release-manifest.json` contains the following name-value pairs:

```
{
	"release-branch-hash": "150963b",	# start release branch here
	"release-branch-prefix": "release/",	# e.g. name branch "release/2.2.0"
	"release-level": "patch",		# major, minor, patch
}
```
