# Adding Pipelines

This repository is designed to manage many pipelines through small YAML registry entries and a single deployment CLI.

## Requirements

Before adding a pipeline, the source repository must provide:

1. A release tag matching `vMAJOR.MINOR.PATCH`.
2. A reproducible dependency lockfile or equivalent.
3. A CLI command that can run through its declared runtime.
4. A test command suitable for deployment verification.

## Add a registry entry

Create a file in `pipelines/` named after the pipeline:

```yaml
name: example_pipeline
display_name: Example Pipeline
description: Short human-readable summary of what the pipeline does.
keywords:
  - keyword one
  - keyword two
use_cases:
  - Explain the main biological question this pipeline helps answer.
  - Explain the input data type users should have.
example_args:
  - --help
repository: https://github.com/BioGeMT/example_pipeline.git
runtime: uv
command: example-pipeline
test_command: pytest

release_policy:
  required: true
  tag_pattern: '^v[0-9]+\.[0-9]+\.[0-9]+$'
```

## Validate registry

```bash
make doctor
```

Check how the pipeline appears in the catalog:

```bash
make list
make info PIPELINE=example_pipeline
make doctor
```

## Deploy

```bash
make deploy PIPELINE=example_pipeline RELEASE=v0.1.0
```

## Scale-out model

Each pipeline gets its own release directory:

```text
/srv/biogemt/pipelines/<pipeline>/releases/<release>
```

The active release is always:

```text
/srv/biogemt/pipelines/<pipeline>/current
```

This keeps rollback simple and lets different pipelines move independently.
