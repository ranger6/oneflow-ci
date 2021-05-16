# Pipeline Operation

## Code Structure

A design principle is that the "code under ci" does not include any ci specific artifacts.
This means different ci tools can be adopted without touching the main code.

For now, this means that one should be able to add the `ci` directory to the "code under ci" and then adapt the pipeline tasks as needed.  More structured approaches--git sub-modules, well defined hooks in the ci tasks, etc.--might come later.

Note, however, that it might be the case that changes to the "code under ci" is modified
during the release process.  For example, metadata (e.g. version) might be injected into "latest stable version" badges or what not.  Another example might be the automated generation of
release notes.

### the `ci` directory

The concourse ci artifacts (pipeline and task configurations, parameters, etc.) are all
contained in the top-level `ci` directory.  The ci artifacts depend on this placement
of the ci directory.

One important exception to this "all in the ci directory" rule is that certain sensitive information is stored in a keystore.  This project has been tested using Vault.  Other keystores should work.  At present, the following variables are found in the keystore:

-  `concourse-git-url`
-  `concourse-git-private-key`

#### the main pipeline

There is a single pipeline defined in `ci/pipeline.yml`  One can name the pipeline as
one wishes.  Here, the convention is to name it `release-pipe`.  There is no assumption
about the user or group running the pipeline.  Note, however, that the placement/naming
of secrets in the keystore may depend on this and/or the pipeline name.

#### the resources

With the exception of `version`, the ("git") resources track branches from a single repository.
The `version` resource is a `semver`.

The long lived branches and their corresponding resources
are described in the [main readme](../README.md) file.

Two resources are used to track the (dynamically created) release branch.

|resource |resource-branch |branch-name |
--- | --- | ---
|release|release-branch|\<prefix\>/\<version\>|
|release-base|release-branch|\<prefix\>/\<version\>|

`release` is used to track commits (i.e. resource versions) that "move" through
the pipeline in a conventional manner. `release-base`, on the other hand, is
used only by the "start-release" job to write the new release branch and
optional release contents to
the `main` repository. This is admittedly tricky, but is needed because:

1.  The `release` resource has not been correctly defined at this point.  It becomes defined
only after the `set_pipeline` step is performed.
2.  To avoid the `unit-test` job running multiple times when the release branch is
first created (once when the branch is created, a second time when a `content`
commit is made to the branch), the `release` resource must discover (i.e. `check`)
the newly created branch only after it is "stable".  So, the sequence is:

    a. create the branch in the `branch` task

    b. commit any new content to this branch in the `content` task

    c. `put` this new branch via the `release-base` resource

    d. set the pipeline with the new release branch name used to parameterize the `release` resource.

    e. the subsequent `check` by the (newly set/parameterized) `release` resource should discover the latest version of the new release branch


#### the tasks

All tasks are factored out of the pipeline by using separate task definition files.  These
files invoke shell scripts.  Each task has its own sub-directory in `ci`.  The naming is
more or less consistent: the job names in the pipeline have names "close" to the
names of the task they invoke.

|job name|task(s) invoked|task definition|shell script|
--- | --- | --- | ---
start-release | branch, content | branch/branch.yml, content/content.yml | branch.sh, content.sh
unit-test | unit | unit/unit.yml | unit.sh
prepare-release | prepare | prepare/prepare.yml | prepare.sh
release | release | release/release.yml | release.sh
update-stable | update | update/update.yml | update.sh
merge-main | merge | merge/merge.yml | merge.sh
clean | clean | clean/clean.yml | clean.sh

The shell scripts are invoked at the top level.  That is, the `dir-path` is not set.

### `ci` code used for the release

The ci code is, of course, versioned.  When a new release branch is created from
a specific commit, the ci code used is the version on that branch.  This supports well
defined and repeatable builds (well, releases).

The release branch, once created, is available as the `release` resource. Hence, one
sees the references to task definition files and scripts in the form of
`./release/ci/<task-dir>/<file>`.

As explained below, the release branch is created by the pipeline (in `start-release`).
Then, where does the code for the `start` task come from?  That is, what version (commit) of
`start/start.yml` or `start/start.sh` is
used when the `start` task is executed in the main pipeline?
The answer is "the most recent version from the `main` resource (often the `main`, `master`, or
`develop` branch depending on name preferences)."  This might not be code identical
to the `start/start.sh` on the (to be created) release branch.  It might be well ahead
or behind that of the commit where the release branch will start.

This is a bootstrap issue.  Hence, the `start` definitions and scripts should be
"handled with care" in order to preserve repeatable and auditable builds.  The `start-release` job needs
to create the new release branch according to the manifest and then set the pipeline
using the version on that new branch.

In fact, it is even a bit more complicated than this. As the `release-pipe` is
set after creating the release branch (see the final step in the `start-release`
job in `ci/pipeline.yml`), it is this pipeline setting that not only produces the release;
it also waits for the next `manifest` to appear for the *subsequent* release.  Of course,
the pipeline can be re-set using `fly` at any point.  Fortunately, one is not
tied to the pipeline definition from the last release in order to kick off the
next release!

Tricky code: the `set_pipeline` step in `start-release` references the `main` resource
(rather than the `release` resource .. which is not even well defined at this point).
However, it is not designating the tip of this branch!  The new release branch was
created by checking out the commit hash given in the manifest in the `start` task.

As a practical matter, when releases only show up weeks or months apart, keeping
the `release-pipe` running does not make sense.  Might as well kick off the
pipeline when it's time to start the release process.  If releases are coming
one after another, then having the previous pipeline definition kick off the
next is also not a problem: it is doubtful that the bootstrap process is changing
at this pace, so nothing breaks even if the rest of the ci code changing.

As well, the "oneflow" model is predicated on "one release at a time" and a "single sequence of releases".  This is not a pipeline that keeps track of multiple releases
in progress and the
confusion attendant with having the right version of the ci for each one.

### Using `ci` for Real Stuff

Assuming that the `ci` directory does not already exist in a project/repo and
one wishes to add this "oneflow" release code to the project, the steps are
straightforward:

1.  Copy the ci directory at the top level.
2.  Follow the steps outlined below for "Initial Setup"
3.  Adapt the shell scripts as needed.  For example, replace the dummy `unit.sh` script
with real unit tests
4.  There are two "placeholders" for injecting project/repo specific logic:
    a. Modification of the "content.sh" script that is executed as part of the `start-release` job.  This is where where release-specific content can be added to the code base.  This task is run once per release.
    b. Addition of pipeline stages between `unit-test` and `prepare-release`.  Each stage should consume/pass the `release` and `version` resource version streams, normally triggering on a new `release` version.

If there is other ci code, then more significant integration is needed (TODO: remove top-level dependencies).

## Parameters and Variables

## Initial Setup

Besides defining the branch names in `ci/vars.yml` as described above, other
variables might be defined there.  At present, two git option values are defined:

-  git-user-name
-  git-user-email

One needs to insure that a certain amount of source (repo) configuration
is done:

1.  Of course, the long running branches used by "oneflow" need to exist.
An initial
release does not need to exist, but the stable branch tip should
point to some commit on the main branch so that it can be fast-forwarded
to the next release that is created.  The initial commit on `main` would
be a good choice.

2.  The branches used for the release manifest and semantic version string
must not be on the main branch.  They should be on "orphan" branches.  It
is fine to use the same branch for both the manifest and the semver.  See
[Version Setup](./VERSION_SETUP.md) for an example.

3.  You will need `concourse` running before you can start a pipeline. See
[concourse-docker](https://github.com/ranger6/concourse-docker) for one
example.

4.  If you are not going to define sensitive information via the `ci/vars.yml` file
(good idea!), then you will need to provide them via a keystore.  An example
integration of `concourse` with `vault` is found in [vault-docker](https://github.com/ranger6/vault-docker).

5.  The general logic for a release is that the release pipeline is triggered by
the publication (new version) of the `release-manifest.json` file.  If you set
the pipeline (e.g. via `fly`) and this file is present, the release pipeline
will be triggered.  This may not be what you want!  For example, if you are
changing some of the ci code and you destroy and then (re-)set the pipeline, you
probably do not want a new release started for the main code base.  To avoid
this, you can:

    - keep the pipeline "paused" until you publish a new release manifest
    - don't set the pipeline until you are ready
    - make sure that the release manifest file does not exist prior to setting the pipeline

The pipeline needs to be set. From the top-level directory, for example:

```
$ fly -t <target> sp -p release-pipe -c ci/pipeline.yml --var release-branch=release/0.0.0 -l ci/vars.yml
```

N.B. The `release-branch` is fictitious.  It is needed so that the pipeline can be elaborated
without errors.  The `release` resource will start looking for it, not find it, and keep trying.When a new release manifest is published, a new release branch will be determined and created.
The pipeline will (re-)set itself with this new variable setting and off we go!

## Creating a Release

It is easier to understand the process of creating a release if you first read the [oneflow](https://www.endoflineblog.com/oneflow-a-git-branching-model-and-workflow) article.  The
concourse pipeline essentially automates this process.

However, making a release *does* require human intervention.  No, not every push is a release.

### The Human Process

1.  Identify the release.
2.  Create the release manifest.
3.  Iterate over release candidates.
4.  Open the release gate.
5.  Remove the release branch (should not be necessary).

### Release Candidate Sequence

### Removing Release Branches

At present, the release branches created are not deleted by the pipeline.  This is
due to the concourse model and implementation.  This may change in the future (with
"prototypes"?).  For now, the "clean" job is a placeholder (with commented out code
to indicate what we would like to do).

## Damage Control

