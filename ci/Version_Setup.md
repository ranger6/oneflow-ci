# Version Setup

The concourse.ci `semver` resource is used to keep track of version strings. Here, the
git driver is used. The file used to store and semantic version string is on a branch
separate from any of the "code under ci" and separate from the ci code itself.  One
reason this is important is that everytime a new semver value is written, a new
commit is made.  Having these commits on any code branch would create a ton of
clutter.

As a result of using a single, separate branch is that the semver file applies
to the entire repo.  This fits just fine with "oneflow" as only a single release
stream is present.

Besides the semver file, the release manifest is kept on this branch.  This is
not a requirement--it could be on its own branch--but a convenience.

This branch, named "version", contains:

1. A `version` file used by the Concourse semver resource.
2. A `release-manifest` file used to both trigger and configure new releases.
The CI release pipeline is triggered on a change to this file.
The file is loaded (`load_var`) by Concourse to set variables.

The branch can be created and set up with the following git commands:

```
git checkout --orphan version
git rm --cached -r .
rm -rf *
rm .gitignore .gitmodules
touch .gitkeep
git add .
git commit -m "new version and release manifest branch"
git push origin version
```

## `release-manifest.json` contains the following name-value pairs (example values):

```
{
	"release-branch-hash": "150963b",	# start release branch here
	"release-branch-prefix": "release/",	# e.g. name branch "release/2.2.0"
	"release-level": "patch",		# major, minor, patch
}
```
