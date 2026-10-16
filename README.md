# BioGeMT Pipelines

BioGeMT Pipelines is a small command-line launcher for running BioGeMT tools on a shared server. It keeps the pipeline code and Python dependencies in versioned Docker images, and gives users one command, `biogemt`, to run them.

This repository contains the launcher and server setup instructions. It does not contain the pipeline source code. The launcher passes pipeline arguments to the container and makes the user's working directory and shared reference data available to it.

## Before you start

Ask your server administrator to set up this repository and make `biogemt` available on your `PATH`. You need:

- Docker installed and running on the server, with your account allowed to use it.
- Access to the BioGeMT pipeline image in GitHub Container Registry (GHCR). If the image is public, Docker can download it without login; otherwise, log in with an account that has package read access.
- An input TSV and either a GTF file or network access to download an Ensembl GTF.

Administrators can follow [the shared server setup guide](docs/server-setup.md).

## Find and inspect commands

List the available pipelines and check that the server is ready:

```bash
biogemt list
biogemt doctor
```

The current pipeline is `genomic-region-annotator`. To see all options for a command, pass `--help` after the pipeline command:

```bash
biogemt run genomic-region-annotator --help
biogemt run genomic-region-annotator annotate --help
biogemt run genomic-region-annotator summarize-sites --help
```

Everything after the pipeline name is passed to that pipeline's command inside Docker.

## Run an annotation

Run commands from a work directory that contains your input file and where you want results written. The input TSV must contain `chr`, `start`, `end`, and `strand` columns. Coordinates are treated as 1-based inclusive by default; add `--coords bed` for 0-based, half-open BED coordinates.

For example, a tab-separated input can start like this:

```text
chr	start	end	strand
1	1000	1050	+
```

For example, to use a GTF already in your work directory:

```bash
cd /path/to/your/work
biogemt run genomic-region-annotator annotate \
  --input regions.tsv \
  --gtf annotation.gtf \
  --output results/regions.tsv \
  --report
```

Use exactly one of `--gtf` or `--release`. To download an Ensembl GTF for the run instead, replace `--gtf annotation.gtf` with `--release 115`. The default species is human (`homo_sapiens`); use `--species` and, if needed, `--assembly` to select another reference. Choose a release and assembly that match your analysis.

`annotate` is step 1: it records transcript overlap evidence. `--output` is the output base name, not a single TSV file. The command writes these files under `results/step1/`:

- `regions_input_with_ids.tsv`: input rows with stable IDs
- `regions_matrix.tsv`: region-overlap evidence
- `regions_transcripts.tsv`: overlapping transcripts
- `regions_step1_stats.tsv`: run statistics

`summarize-sites` is step 2: it applies the default transcript-selection policy (`clash_utr3_first`) and summarizes region coverage. Run it to produce the final summaries:

```bash
biogemt run genomic-region-annotator summarize-sites \
  --transcripts results/step1/regions_transcripts.tsv \
  --matrix results/step1/regions_matrix.tsv \
  --input-with-ids results/step1/regions_input_with_ids.tsv \
  --report
```

This writes the site summary, final table, and statistics under `results/step2/`. The main result is `results/step2/regions_final.tsv`.

## Where files are visible

The launcher mounts the directory where you run `biogemt` into the container at the same path, with read-write access. Relative paths such as `regions.tsv` and `results/regions.tsv` are resolved from that directory. The container also receives `BIOGEMT_DATA` as a read-only mount for shared reference files.

Files outside your working directory and `BIOGEMT_DATA` are not available inside the container. If your GTF is in the shared data directory, pass its path there, for example:

```bash
--gtf /srv/biogemt/data/genomic-region-annotator/annotation.gtf
```

When using `--release`, the downloaded GTF and cache are stored in the working directory by default (`data/annotations/` and `.cache/genomic-region-annotator/`). You can change those locations with `--outdir` and `--cache-dir`.

## Configuration

The default shared paths are:

```text
BIOGEMT_ROOT=/srv/biogemt
BIOGEMT_DATA=/srv/biogemt/data
```

The server administrator can create `config/server.env` from [`config/server.env.example`](config/server.env.example) and change the paths. If only `BIOGEMT_ROOT` is changed, `BIOGEMT_DATA` defaults to its `data/` subdirectory. Set `BIOGEMT_DATA` explicitly if reference files are stored elsewhere. `config/server.env` is ignored by Git. To use a different config file, set `BIOGEMT_CONFIG=/path/to/server.env`.

The current pipeline image is `ghcr.io/biogemt/genomic-region-annotator:0.1.0`. For local testing, set `BIOGEMT_GENOMIC_REGION_ANNOTATOR_IMAGE` to override it.

## Repository layout

- `bin/biogemt`: user-facing command and pipeline dispatch
- `pipelines/<name>/run.sh`: Docker invocation for each pipeline
- `scripts/doctor.sh`: server and image diagnostics
- `config/`: example server configuration
- `docs/`: server setup and maintainer guidance

See [Adding a Pipeline](docs/adding-a-pipeline.md) for the small, explicit steps to add another tool.
