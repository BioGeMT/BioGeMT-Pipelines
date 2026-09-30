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

Install the Genomic Region Annotator pipeline:

```bash
./scripts/install.sh
```

Install a specific branch, tag, or commit:

```bash
./scripts/install.sh v0.1.0
```

## Verify installation

Run the wrapper with the pipeline help command:

```bash
./scripts/run.sh --help
```

## Update pipeline

Production updates should use explicit versions, tags, or pinned commits. Avoid deploying by pulling `main` directly.

```bash
./scripts/update.sh v0.2.0
```

The update script performs:

1. Checks that the installed pipeline has no local changes.
2. `git fetch --tags`
3. `git checkout <version>`
4. `uv sync --frozen`
5. `uv run pytest`

## Rollback pipeline

Rollback is the same operation with a previous known-good version:

```bash
./scripts/update.sh v0.1.0
```

For urgent manual rollback inside the installed pipeline directory:

```bash
cd /srv/biogemt/pipelines/genomic_region_annotator
git checkout v0.1.0
uv sync --frozen
```

## Notes

- Source code remains in `BioGeMT/genomic_region_annotator`.
- Runtime data belongs under `/srv/biogemt/data`.
- Pipeline run outputs belong under `/srv/biogemt/runs`.
- Logs belong under `/srv/biogemt/logs`.
- Server-specific configuration can be stored in `config/server.yaml`, which is intentionally ignored by Git.
