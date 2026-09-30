# Run Directories

BioGeMT Pipelines keeps source code, shared reference data, and user run outputs separate.

## Default location

Runs are stored under:

```text
/srv/biogemt/runs/<pipeline>/<run_id>/
```

For example:

```text
/srv/biogemt/runs/genomic_region_annotator/20261001T120000Z/
├── output/
├── logs/
└── tmp/
```

## Run IDs

If no run ID is provided, the controller creates a UTC timestamp such as:

```text
20261001T120000Z
```

For a named run, use the direct CLI:

```bash
make run PIPELINE=genomic_region_annotator RUN_ID=my_analysis_001 ARGS='-- --help'
```

## Environment variables for pipelines

Each pipeline receives:

| Variable | Meaning |
| --- | --- |
| `BIOGEMT_RUN_ID` | Current run identifier |
| `BIOGEMT_RUN_DIR` | Root directory for the current run |
| `BIOGEMT_OUTPUT_DIR` | Main output directory for result files |
| `BIOGEMT_LOG_DIR` | Log directory for the current run |
| `BIOGEMT_TMP_DIR` | Temporary directory for the current run |
| `BIOGEMT_DATA_DIR` | Shared reference data directory |

Pipeline code should write durable result files to `BIOGEMT_OUTPUT_DIR` and logs to `BIOGEMT_LOG_DIR`.

## Recommended output structure

```text
output/
├── results.tsv
├── summary.json
└── figures/
```

This keeps outputs predictable for downstream reporting and visualization.
