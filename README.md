# concourse-ci pipelines to automate the "oneflow" release process

This is a prototype and sandbox repository for developing generic
[concourse-ci](https://concourse-ci.org/) pipelines that automate
the [oneflow](https://www.endoflineblog.com/oneflow-a-git-branching-model-and-workflow)
git branching model and workflow (at least for the release part).

Don't expect stable code or a sane commit history: this same repo is often
used for sandbox prototyping and testing.  The pipeline generates releases
of itself.  Someday, the real use will be using this generic pipeline for
other content.

## docs

See the [README](./ci/README.md) in the `ci` directory for details of
concourse operation.

Below is a somewhat higher level description of the approach.

### branches

1.  The main development branch is "develop" (following the convention in oneflow).
2.  The stable branch is "master".  The tip of master always points to the
latest release. This is *one* suggestion for "oneflow" naming.
3.  The "version" branch is used by the ci pipeline as the external source
of truth for the semver version.  It is also where the
release manifest is published to trigger new releases.  This is *not* part
of oneflow.
4.  Release branches get created, but should be removed once the final release
is tagged and merged back into master.  However, this is not yet automated so
one may find multiple garbage branches.

Because people may want to use different names for branches in oneflow, the branch
names are factored out from the concourse resources. The coorespondance is
captured in `ci/vars.json`.  For *this* repo, we use "develop" and "master" as
the two long-lived branches.  We use "version" to store the release manifests
and the semver version string. The release branches are dynamically created and
are short lived.

Here then, is the mapping used for this repo (again, see `ci/vars.yml`).  If you
want to use different branch names, then just change the "branch-name"!

|resource |resource-branch |branch-name |
--- | --- | ---
|main|main-branch|develop|
|stable|stable-branch|master|
|version|version-branch|version|
|manifest|manifest-branch|version|

### tags

Semantic versioning is used. The current ci pipeline always creates release
candidate tags.  This is not a requirement.

### releases

Only the tagging is done.  No github releases yet.

### pipelines

"release-pipe" is mostly linear:

1.  New release manifests pushed to the version branch trigger the "start-release" job.
It creates a new release branch and sets the "version" semver to the next *target* version.
2.  It then sets `self` to an updated version of `ci/pipeline.yml`  The code does not change.
Only the "release-branch" variable is changed to the just generated release branch.  That is,
the "release" resource is following the newly created release branch.
3.  New versions on the release branch trigger "prepare-release"
4.  If tests pass, a new release candidate is tagged.
5.  When someone decides that all is ok, the "release" job is manually triggered.
6.  "release" tags the latest release candidate with the final target release and then merges
the release branch back to the develop branch.
7.  A new release triggers "update-stable" that fast-forwards the stable branch
to the new release tag.
8.  "clean" should then delete the release branch (not working yet).

## dependencies

1.  The github private information and URL's are held in a keystore (Vault).
2.  Currently, version 7.0 of concourse is being used running in Docker.
3.  The [image](https://github.com/ranger6/alpine-extras) used for
several tasks includes git and bash.

## history

### two pipelines

An initial prototype used two pipelines: start-release and prepare-release.  This
introduced a resource race condition.

> There is a long (forever) running pipeline ("start-release" `ci/start/pipeline.yml`) that triggers on new release configurations pushed to the version branch.  It creates a new release branch and then sets the "prepare-release" pipeline (`ci/pipeline.yml`) that pushes the release to conclusion (or abandonment).
