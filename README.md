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

Not much yet.  Here's what we've got:

### branches

1.  The main development branch is "develop" (following the convention in oneflow)
2.  The stable branch is "master".  The tip of master always points to the
latest release.
3.  The "version" branch is used by the ci pipeline.  It is also where the
release configuration is published to trigger new releases.  This is *not* part
of oneflow.
4.  Release branches get created, but should be removed once the final release
is tagged and merged back into master.  However, this is not yet automated so
one may find multiple garbage branches.

### tags

Semantic versioning is used. The current ci process always creates release
candidate tags.

### releases

Only the tagging is done.  No github releases yet.

### pipelines

There is a long (forever) running pipeline ("start-release" `ci/start/pipeline.yml`)
that triggers on new release configurations pushed to the version branch.  It creates a new
release branch and then sets the "prepare-release" pipeline (`ci/pipeline.yml`)
that pushes the release to conclusion (or abandonment).

"prepare-release" is mostly linear:

1.  New versions on the release branch trigger "unit"
2.  If tests pass, a new release candidate is tagged.
3.  When someone decides that all is ok, "release" is manually triggered.
4.  "release" tags the latest release candidate and merges back to the
develop branch.
5.  A new release triggers "update-master" that fast-forwards the master branch
to the new release tag.
6.  "clean" should then delete the release branch (not working yet).

## dependencies

1.  The github private information is held in a keystore (Vault).
2.  Currently, version 7.0 of concourse is being used running in Docker.
3.  The [image](https://github.com/ranger6/alpine-extras) used for
several tasks includes git and bash.

