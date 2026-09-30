# Deployment

This document describes the initial server deployment flow for BioGeMT pipelines.

## Server requirements

- Linux server with shell access
- Git
- uv
- Access to the BioGeMT GitHub organization repositories
- Write access to `/srv/biogemt` or a custom `BIOGEMT_ROOT`

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

You can override this root for testing or non-standard deployments:

```bash
export BIOGEMT_ROOT=/path/to/biogemt
```

For persistent server-specific settings, copy the example environment file:

```bash
cp config/server.env.example config/server.env
```

Then edit `config/server.env`. This file is ignored by Git.

## Initial setup

Create the root directory and assign appropriate ownership or group permissions for the server users who will operate the pipelines.

```bash
sudo mkdir -p /srv/biogemt
sudo chgrp -R biogemt /srv/biogemt
sudo chmod -R g+rwx /srv/biogemt
```

Install and activate a released Genomic Region Annotator version:

```bash
make install RELEASE=v0.1.0
```

This creates a release-specific checkout under `releases/` and points `current` to it.

## Verify installation

Run the wrapper with the pipeline help command:

```bash
make run ARGS='--help'
```

## Update pipeline

Production updates should use explicit released versions, tags, or pinned commits. Avoid deploying by pulling `main` directly.

```bash
make deploy RELEASE=v0.2.0
```

The update script performs:

1. Creates or reuses a release-specific checkout under `releases/`.
2. `git fetch --tags`
3. `git checkout <version>`
4. `uv sync --frozen`
5. `uv run pytest`
6. Updates the `current` symlink only after setup and tests pass.

## Rollback pipeline

Rollback is the same operation with a previous known-good version:

```bash
make rollback RELEASE=v0.1.0
```

For urgent manual rollback without `make`, activate the installed release directly:

```bash
./scripts/activate.sh v0.1.0
```

## Notes

- Source code remains in `BioGeMT/genomic_region_annotator`.
- Runtime data belongs under `/srv/biogemt/data`.
- Pipeline run outputs belong under `/srv/biogemt/runs`.
- Logs belong under `/srv/biogemt/logs`.
- Server-specific configuration can be stored in `config/server.yaml`, which is intentionally ignored by Git.
