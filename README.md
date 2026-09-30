# BioGeMT Pipelines

Deployment controller for installing, updating, rolling back, and running BioGeMT research pipelines on shared infrastructure.

This repository does not contain pipeline source code. Each pipeline remains in its own repository and is deployed here only through explicit releases.

## Current pipelines

- `genomic_region_annotator`

## Design principles

- Pipeline source code remains in its own repository.
- Every integrated pipeline must publish versioned releases.
- Production deployments use explicit release tags only.
- Each release is installed in an isolated checkout.
- The active release is selected through a `current` symlink.
- Shared reference data is stored outside pipeline repositories.
- Pipeline runs and results are stored separately from source code.

## Repository layout

```text
BioGeMT-Pipelines/
├── Makefile
├── README.md
├── pyproject.toml
├── pipelines/
│   └── genomic_region_annotator.yaml
├── src/
│   └── biogemt_pipelines/
├── config/
│   └── server.example.yaml
├── docs/
│   ├── adding-pipelines.md
│   ├── deployment.md
│   └── pipeline-policy.md
└── .gitignore
```

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

## CLI workflow

Use the Python CLI through `uv`. The `Makefile` is a convenience wrapper around the same CLI.

List registered pipelines:

```bash
make list
```

Show deployment info:

```bash
make info PIPELINE=genomic_region_annotator
```

Install and activate a release without tests:

```bash
make install PIPELINE=genomic_region_annotator RELEASE=v0.1.0
```

Deploy a release with tests:

```bash
make deploy PIPELINE=genomic_region_annotator RELEASE=v0.2.0
```

Rollback to an already installed release:

```bash
make rollback PIPELINE=genomic_region_annotator RELEASE=v0.1.0
```

Run the active release:

```bash
make run PIPELINE=genomic_region_annotator ARGS='-- --help'
```

Equivalent direct CLI calls:

```bash
uv run biogemt-pipelines deploy genomic_region_annotator --release v0.2.0
uv run biogemt-pipelines rollback genomic_region_annotator --release v0.1.0
uv run biogemt-pipelines run genomic_region_annotator -- --help
```

## Release rule

Every pipeline must publish release tags matching `vMAJOR.MINOR.PATCH`, for example `v0.1.0`.

Moving branches such as `main`, `dev`, or `latest` are not valid deployment targets.

See `docs/pipeline-policy.md` for the full policy.

## Server-specific configuration

Defaults target `/srv/biogemt`. For a specific server, copy the example config and edit it locally:

```bash
cp config/server.example.yaml config/server.yaml
```

`config/server.yaml` is ignored by Git.
