# BioGeMT Pipelines

Central repository for deploying, managing, and running BioGeMT research pipelines on shared infrastructure.

## Current pipelines

- Genomic Region Annotator

## Design principles

- Pipeline source code remains in its own repository.
- Each pipeline has an isolated software environment.
- Production deployments use pinned versions.
- Shared reference data is stored outside pipeline repositories.
- Pipeline runs and results are stored separately from source code.

## Server layout

```text
/srv/biogemt/
├── pipelines/
├── data/
├── runs/
└── logs/
```

## Repository layout

```text
BioGeMT-Pipelines/
├── README.md
├── pipelines/
│   └── genomic_region_annotator.yaml
├── scripts/
│   ├── install.sh
│   ├── update.sh
│   └── run.sh
├── config/
│   ├── server.example.yaml
│   └── server.env.example
├── docs/
│   └── deployment.md
└── .gitignore
```

## Genomic Region Annotator

The Genomic Region Annotator source code lives in its own repository:

```text
https://github.com/BioGeMT/genomic_region_annotator.git
```

This repository only defines how the pipeline is installed, updated, and launched on shared infrastructure.

## Quick start

Install the current pipeline on a server:

```bash
./scripts/install.sh
```

Install a specific branch, tag, or commit:

```bash
./scripts/install.sh v0.1.0
```

Run the pipeline wrapper:

```bash
./scripts/run.sh --help
```

Deploy a pinned release or tag:

```bash
./scripts/update.sh v0.1.0
```

## Server-specific configuration

Defaults target `/srv/biogemt`. For a specific server, copy the environment example and edit it locally:

```bash
cp config/server.env.example config/server.env
```

`config/server.env` is ignored by Git.
