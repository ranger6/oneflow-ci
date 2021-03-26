# Pipeline Operation

## Code Structure

### the `ci` directory

#### the main pipeline

#### the tasks

### `ci` code used for the release

### Using `ci` for Real Stuff

- no ci data in the main code (but "version.txt")

## Parameters and Variables

## Initial Setup

Once the parameters for branch naming have been determined, one
needs to insure that a certain amount of source (repo) configuration
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
[Setting Up the Manifest and semver](./Version_Setup.md) for an example.

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

### Release Candidate Sequence

### Removing Release Branches

At present, the release branches created are not deleted by the pipeline.  This is
due to the concourse model and implementation.  This may change in the future (with
"prototypes"?).  For now, the "clean" job is a placeholder (with commented out code
to indicate what we would like to do).

## Damage Control

