# Adding a Pipeline

This repository intentionally starts with one pipeline and no generic plugin framework.

For a future second pipeline, reassess the launcher shape before generalizing. Until then, keep additions explicit and small:

1. Keep source code in the pipeline's own repository.
2. Publish a versioned Docker image for the pipeline.
3. Add a directory under `pipelines/<pipeline-name>/`.
4. Add a small `run.sh` that pins an explicit image version or digest.
5. Add the pipeline name to `bin/biogemt list` and dispatch in `bin/biogemt run`.
6. Document any required shared reference-data layout.
7. Add an alphabetized row to the Available pipelines table in `README.md`, linking to the upstream repository's usage instructions.

Do not add a scheduler, REST API, web frontend, database, Docker Compose, Kubernetes, Slurm, Nextflow, or a plugin framework until there is a concrete need.
