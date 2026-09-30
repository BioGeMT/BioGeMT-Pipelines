# Deployment

This document describes the server deployment flow for BioGeMT pipelines.

## Server requirements

- Linux server with shell access
- Git
- uv
- Access to the BioGeMT GitHub organization repositories
- Write access to `/srv/biogemt` or a custom root in `config/server.yaml`

The BioGeMT Pipelines controller itself does not require a separate installation step after cloning this repository. Use `uv run` or the provided `make` commands; `uv` creates the local environment automatically on first use.

## Server layout

The default production layout is:

```text
/srv/biogemt/
├── pipelines/
│   └── genomic_region_annotator/
│       ├── current -> releases/v0.1.0
│       └── releases/
├── data/
├── runs/
└── logs/
```

## Server config

For persistent server-specific settings, copy the example config:

```bash
cp config/server.example.yaml config/server.yaml
```

Then edit `config/server.yaml`. This file is ignored by Git.

## Initial setup

Create the root directory and assign appropriate ownership or group permissions for users who will operate the pipelines.

```bash
sudo mkdir -p /srv/biogemt
sudo chgrp -R biogemt /srv/biogemt
sudo chmod -R g+rwx /srv/biogemt
```

Deploy the first Genomic Region Annotator release:

```bash
make deploy PIPELINE=genomic_region_annotator RELEASE=v0.1.0
```

This creates a release-specific checkout under `releases/`, runs the deployment tests, and points `current` to it.

## Verify installation

Run the active release with the pipeline help command:

```bash
make run PIPELINE=genomic_region_annotator ARGS='-- --help'
```

Check the active release:

```bash
make status
```

Run server readiness checks:

```bash
make doctor
```

## Deploy pipeline release

Production updates must use explicit release tags matching `vMAJOR.MINOR.PATCH`. Deploying moving branches is unsupported.

```bash
make deploy PIPELINE=genomic_region_annotator RELEASE=v0.2.0
```

The deploy command performs:

1. Loads the pipeline definition from `pipelines/`.
2. Validates that the release tag matches the pipeline release policy.
3. Creates or reuses a release-specific checkout under `releases/`.
4. Checks out the requested release tag.
5. Runs `uv sync --frozen` inside the pipeline repository.
6. Runs the pipeline test command.
7. Updates the `current` symlink only after setup and tests pass.

## Rollback pipeline

Rollback activates a previous installed release:

```bash
make rollback PIPELINE=genomic_region_annotator RELEASE=v0.1.0
```

If the release is not installed yet, deploy it first.

## Notes

- Source code remains in the pipeline's own repository.
- Runtime data belongs under `/srv/biogemt/data`.
- Pipeline run outputs belong under `/srv/biogemt/runs`.
- Logs belong under `/srv/biogemt/logs`.
- Server-specific configuration belongs in `config/server.yaml`.
