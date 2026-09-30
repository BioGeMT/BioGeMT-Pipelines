# BioGeMT Pipelines

Catalog and runner for BioGeMT research pipelines on shared infrastructure.

This repository does not contain pipeline source code. Each pipeline remains in its own repository and is deployed here only through explicit releases.

## Current pipelines

| Pipeline | What it does | Responsible |
| --- | --- | --- |
| `genomic_region_annotator` | Annotates genomic regions and helps connect BED-like intervals to nearby genes and genomic context. | `zacharopoulou` |

## For Users

After cloning this repository, commands run through `uv`, which creates the local environment automatically on first use.

Browse available pipelines:

```bash
make list
```

Decide whether a pipeline matches your analysis:

```bash
make info PIPELINE=genomic_region_annotator
```

See which release is currently active:

```bash
make status
```

Run the active pipeline:

```bash
make run PIPELINE=genomic_region_annotator ARGS='-- --help'
```

For a named run, set `RUN_ID`:

```bash
make run PIPELINE=genomic_region_annotator RUN_ID=my_analysis_001 ARGS='-- --help'
```

The actual pipeline software must already be deployed on the shared server before users can run it. Deployment is an administrator action.

## Run Output Layout

Each run gets a structured directory under `/srv/biogemt/runs/<pipeline>/<run_id>/`.

```text
/srv/biogemt/runs/genomic_region_annotator/<run_id>/
├── output/
├── logs/
└── tmp/
```

The controller exposes these paths to pipelines through environment variables:

| Variable | Meaning |
| --- | --- |
| `BIOGEMT_RUN_ID` | Current run identifier |
| `BIOGEMT_RUN_DIR` | Root directory for the current run |
| `BIOGEMT_OUTPUT_DIR` | Main output directory for result files |
| `BIOGEMT_LOG_DIR` | Log directory for the current run |
| `BIOGEMT_TMP_DIR` | Temporary directory for the current run |
| `BIOGEMT_DATA_DIR` | Shared reference data directory |

This structure keeps user results organized and gives us a stable base for later visualization.

## For Administrators

Check that the server and registry are ready:

```bash
make doctor
```

Deploy a tested release:

```bash
make deploy PIPELINE=genomic_region_annotator RELEASE=v0.2.0
```

Rollback to a previous release:

```bash
make rollback PIPELINE=genomic_region_annotator RELEASE=v0.1.0
```

Equivalent direct CLI calls:

```bash
uv run biogemt-pipelines deploy genomic_region_annotator --release v0.2.0
uv run biogemt-pipelines rollback genomic_region_annotator --release v0.1.0
uv run biogemt-pipelines run genomic_region_annotator -- --help
```

## Design Principles

- Pipeline source code remains in its own repository.
- Every integrated pipeline must publish versioned releases.
- Production deployments use explicit release tags only.
- Each release is installed in an isolated checkout.
- The active release is selected through a `current` symlink.
- Shared reference data is stored outside pipeline repositories.
- Pipeline runs and results are stored separately from source code.
- Pipeline metadata should help users decide which pipeline they need.

## Repository Layout

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
│   ├── pipeline-policy.md
│   ├── runs.md
│   └── visualization.md
└── .gitignore
```

## Server Layout

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

## Release Rule

Every pipeline must publish release tags matching `vMAJOR.MINOR.PATCH`, for example `v0.1.0`.

Moving branches such as `main`, `dev`, or `latest` are not valid deployment targets.

See `docs/pipeline-policy.md` for the full policy.

## Server-Specific Configuration

Defaults target `/srv/biogemt`. For a specific server, copy the example config and edit it locally:

```bash
cp config/server.example.yaml config/server.yaml
```

`config/server.yaml` is ignored by Git.
