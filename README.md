# BioPipelines

This repository is the shared-server launcher for BioGeMT pipelines. It provides one command, `BioPipelines`, to run supported pipeline Docker images. Pipeline code and pipeline-specific usage instructions live in each pipeline's own repository.

## Available pipelines

The table lists pipelines wired into this launcher. Other BioGeMT repositories are not available through `BioPipelines` unless they are added here.

| Launcher name | Purpose | Pipeline and usage guide |
| --- | --- | --- |
| `genomic-region-annotator` | Annotates genomic intervals using Ensembl GTF data. | [Repository and usage](https://github.com/BioGeMT/genomic_region_annotator#usage) |

If you are running from a checkout and `BioPipelines` is not on your `PATH`, either use the launcher path directly:

```bash
bin/BioPipelines list
```

or add this checkout's `bin/` directory to `PATH` for the current shell:

```bash
export PATH="$PWD/bin:$PATH"
```

Then list the pipelines available in your checkout:

```bash
BioPipelines list
```

## How to run a pipeline

Use the pipeline's repository linked above for its inputs, options, and workflow. Run its command through this launcher by prefixing it with `BioPipelines run <launcher-name>`:

```bash
BioPipelines run <launcher-name> <pipeline-command> [options]
```

For example, to see the available commands and options for the current pipeline:

```bash
BioPipelines run genomic-region-annotator annotate --help
```

The launcher passes the remaining arguments to the pipeline container. It mounts the current directory read-write and the configured shared reference-data directory read-only.

## Server setup

Docker must be installed and running, and your account must be able to use it. The server must also be able to access each pipeline image in GitHub Container Registry (GHCR). Ask the server administrator to set this up using the [shared-server setup guide](docs/server-setup.md).

## Maintainers

See [Adding a Pipeline](docs/adding-a-pipeline.md) for how to wire another pipeline into the launcher and add it to this catalogue.
