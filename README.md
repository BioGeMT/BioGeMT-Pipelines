# BioGeMT Pipelines

Central repository for deploying, managing, and running BioGeMT research pipelines on shared infrastructure.

## Current pipelines

- Genomic Region Annotator

## Design principles

- Pipeline source code remains in its own repository.
- Each pipeline has an isolated software environment.
- Production deployments use pinned versions.
- Every integrated pipeline must publish versioned releases.
- Shared reference data is stored outside pipeline repositories.
- Pipeline runs and results are stored separately from source code.

## Server layout

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

## Repository layout

```text
BioGeMT-Pipelines/
├── Makefile
├── README.md
├── pipelines/
│   └── genomic_region_annotator.yaml
├── scripts/
│   ├── activate.sh
│   ├── install.sh
│   ├── update.sh
│   └── run.sh
├── config/
│   ├── server.example.yaml
│   └── server.env.example
├── docs/
│   ├── pipeline-policy.md
│   └── deployment.md
└── .gitignore
```

## Genomic Region Annotator

The Genomic Region Annotator source code lives in its own repository:

```text
https://github.com/BioGeMT/genomic_region_annotator.git
```

This repository only defines how the pipeline is installed, updated, and launched on shared infrastructure.

## Release-based deployment

Production deployments should use explicit released versions, tags, or pinned commits. Do not deploy production by implicitly tracking `main`.

Integrated pipelines must publish release tags matching `vMAJOR.MINOR.PATCH`; see `docs/pipeline-policy.md`.

Install and activate a released version on a server:

```bash
make install RELEASE=v0.1.0
```

Run the active release through the `current` symlink:

```bash
make run ARGS='--help'
```

Activate another released version:

```bash
make deploy RELEASE=v0.2.0
```

Rollback by re-activating a previous release:

```bash
make rollback RELEASE=v0.1.0
```

The underlying scripts are still available for automation:

```bash
./scripts/install.sh v0.1.0
./scripts/update.sh v0.2.0
./scripts/activate.sh v0.1.0
```

## Server-specific configuration

Defaults target `/srv/biogemt`. For a specific server, copy the environment example and edit it locally:

```bash
cp config/server.env.example config/server.env
```

`config/server.env` is ignored by Git.
