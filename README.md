# BioGeMT Pipelines

Deployment controller for running BioGeMT research pipelines on shared infrastructure.

This repository does not contain pipeline source code. Each pipeline remains in its own repository and is deployed here only through explicit releases.

## Current pipelines

| Pipeline | What it does |
| --- | --- |
| `genomic_region_annotator` | Annotates genomic regions and helps connect BED-like intervals to nearby genes and genomic context. |

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

## Simple workflow

Most users only need `make run`. Administrators use `make deploy` when a new pipeline release is ready.

After cloning this repository, no manual installation step is required for the BioGeMT Pipelines controller. Commands run through `uv`, which creates the local environment automatically on first use.

Check that the controller works:

```bash
make list
```

The actual pipeline software must already be deployed on the shared server before users can run it. Deployment is an administrator action.

Browse available pipelines:

```bash
make list
```

See which release is currently active:

```bash
make status
```

Learn whether a pipeline matches your analysis:

```bash
make info PIPELINE=genomic_region_annotator
```

Run the active pipeline:

```bash
make run PIPELINE=genomic_region_annotator ARGS='-- --help'
```

Deploy a tested release:

```bash
make deploy PIPELINE=genomic_region_annotator RELEASE=v0.2.0
```

Rollback to a previous release:

```bash
make rollback PIPELINE=genomic_region_annotator RELEASE=v0.1.0
```

## Admin commands

Use the Python CLI through `uv`. The `Makefile` is a convenience wrapper around the same CLI.

Show deployment info:

```bash
make info PIPELINE=genomic_region_annotator
```

Check that the server and registry are ready:

```bash
make doctor
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
