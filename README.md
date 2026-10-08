# BioGeMT Pipelines

Small deployment and launcher repository for BioGeMT research pipelines on a shared lab server.

This repository does **not** contain pipeline source code. Individual pipelines remain in their own repositories and publish Docker images. This repository provides server-facing launchers that hide ordinary Docker usage from lab users.

## Current Pipelines

```text
genomic-region-annotator
```

## Quick Start

Add `bin/` to your `PATH` or run commands from this repository:

```bash
bin/biogemt list
```

Run the Genomic Region Annotator through Docker:

```bash
bin/biogemt run genomic-region-annotator \
  annotate \
  --input input.tsv \
  --gtf annotation.gtf \
  --output results/output.tsv
```

Users do not need to run `conda activate`, `pip install`, `uv sync`, clone `genomic_region_annotator`, or call `docker run` directly.

## Configuration

Defaults target the shared server layout under `/srv/biogemt`:

```bash
BIOGEMT_ROOT=/srv/biogemt
BIOGEMT_DATA=/srv/biogemt/data
BIOGEMT_RUNS=/srv/biogemt/runs
```

For server-specific paths, copy and edit:

```bash
cp config/server.env.example config/server.env
```

`config/server.env` is intentionally ignored by Git. You can also point to another config file with `BIOGEMT_CONFIG=/path/to/server.env`.

## Server Layout

```text
/srv/biogemt/
├── data/
│   └── genomic-region-annotator/
├── runs/
│   └── genomic-region-annotator/
├── cache/
│   └── genomic-region-annotator/
└── logs/
```

Reference datasets live outside Docker images and should be mounted at runtime. Source-code checkouts and Python environments are not stored in `/srv/biogemt` for containerized tools unless future deployment tooling requires them.

## Commands

```bash
bin/biogemt list
bin/biogemt doctor
bin/biogemt run genomic-region-annotator --help
```

The current pinned image is:

```text
ghcr.io/biogemt/genomic-region-annotator:0.1.0
```

Production should pin an explicit version or digest, not `latest`.
For local testing, `BIOGEMT_GENOMIC_REGION_ANNOTATOR_IMAGE` can temporarily override this image.
