# Visualization Roadmap

The current repository is ready to support visualization later, but visualization should be built on top of stable run outputs rather than hardcoded pipeline internals.

## What we need first

Each pipeline should declare:

- input formats
- output formats
- expected result files
- whether visualization is ready

This metadata lives in `pipelines/*.yaml`.

## Stable base for visualization

The controller creates a predictable run directory:

```text
/srv/biogemt/runs/<pipeline>/<run_id>/output/
```

Visualization tools can read from that directory without knowing where the pipeline source code is installed.

## Likely next step

For each pipeline, define a small machine-readable summary output, for example:

```text
output/summary.json
```

Then a future visualization layer can render:

- run summary
- result table previews
- downloadable output files
- figures or genome-region views when available

## Current status

`genomic_region_annotator` is not marked visualization-ready yet. First, we should confirm its stable output filenames and create a small example run.
