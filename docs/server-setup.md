# Shared Server Setup

This first version supports one Docker-backed pipeline: `genomic-region-annotator`.

## 1. Install Docker Engine

Install Docker Engine using the operating system's recommended process. Do not use this repository to automate host-level Docker installation.

## 2. Decide the Docker Security Model

Membership in the normal `docker` group effectively grants root-level privileges on the host, because users can start containers with broad filesystem access.

For a shared lab server, evaluate rootless Docker or another restricted operational model before casually adding every lab user to the unrestricted Docker group.

## 3. Clone BioGeMT-Pipelines

```bash
git clone https://github.com/BioGeMT/BioGeMT-Pipelines.git
cd BioGeMT-Pipelines
```

## 4. Configure BioGeMT Paths

Create the shared directory layout, using whatever ownership and permissions match the lab's security model:

```text
/srv/biogemt/
├── data/
│   └── genomic-region-annotator/
├── runs/
│   └── genomic-region-annotator/
├── cache/
│   └── genomic-region-annotator/
└── logs/
```

Copy the example config and edit it if the server uses different paths:

```bash
cp config/server.env.example config/server.env
```

Default values are:

```bash
BIOGEMT_ROOT=/srv/biogemt
BIOGEMT_DATA=/srv/biogemt/data
BIOGEMT_RUNS=/srv/biogemt/runs
```

Reference datasets, including downloaded Ensembl GTF files, live under shared data paths outside Docker images.

## 5. Put `biogemt` on PATH

For one shell:

```bash
export PATH="$PWD/bin:$PATH"
```

For all users, install or symlink `bin/biogemt` into a shared location that is already on `PATH`, such as `/usr/local/bin`, according to local administrator policy.

## 6. Pull and Test the Image

```bash
docker pull ghcr.io/biogemt/genomic-region-annotator:0.1.0
docker run --rm ghcr.io/biogemt/genomic-region-annotator:0.1.0 --help
```

## 7. Run Doctor

```bash
biogemt doctor
```

`doctor` checks Docker availability, Docker daemon access, configured shared paths, and whether the configured image is locally available or resolvable from GHCR. It does not modify the system.

## 8. Run a Small Test Annotation

From a directory containing small test files:

```bash
biogemt run genomic-region-annotator \
  annotate \
  --input input.tsv \
  --gtf annotation.gtf \
  --output results/output.tsv
```

Generated files are written through the mounted current directory and should be owned by the invoking host user.
