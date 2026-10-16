# Set Up a Shared Server

This guide is for the administrator preparing a server for lab users. Set up the launcher once; users can then follow the [usage guide](../README.md#run-an-annotation).

BioGeMT Pipelines runs tools in Docker images. It does not install Docker, download reference data, or install pipeline code on the host.

## 1. Install and secure Docker

Install Docker Engine using the procedure recommended for the server's operating system. Make sure Docker is running and that each intended user can run Docker commands.

Choose the server's Docker security model before granting access. Membership in the normal `docker` group effectively grants root-level privileges on the host. For a shared lab server, assess rootless Docker or another restricted setup before adding users to that group.

## 2. Clone this repository

Place the checkout in a stable location that all intended users can read and execute:

```bash
git clone https://github.com/BioGeMT/BioGeMT-Pipelines.git
cd BioGeMT-Pipelines
```

Do not put the shared checkout in an administrator's private home directory if other users need to run it.

## 3. Prepare the shared reference-data directory

The default shared-data path is `/srv/biogemt/data`. Create it and give intended users read access to the directory and its files. For example:

```bash
sudo mkdir -p /srv/biogemt/data/genomic-region-annotator
```

Use the server's normal group and permissions policy for reference files. The launcher mounts this directory read-only in containers. Put GTF files and other shared references there; users pass their paths with options such as `--gtf`.

## 4. Configure paths (optional)

The defaults are:

```text
BIOGEMT_ROOT=/srv/biogemt
BIOGEMT_DATA=/srv/biogemt/data
```

If these paths suit the server, no config file is needed. Otherwise, create a local config and edit it:

```bash
cp config/server.env.example config/server.env
```

Set `BIOGEMT_ROOT` to the shared BioGeMT directory. If `BIOGEMT_DATA` is omitted, it defaults to `$BIOGEMT_ROOT/data`. Set it explicitly when reference data is elsewhere. The file is sourced as a shell config, so keep it to trusted variable assignments. It is ignored by Git.

## 5. Make the command available to users

For a quick check from the checkout:

```bash
bin/biogemt list
```

To make `biogemt` available on every user's `PATH`, create a symlink in a shared command directory. Run this from the repository checkout:

```bash
sudo ln -s "$(pwd)/bin/biogemt" /usr/local/bin/biogemt
```

The launcher resolves the repository location through the symlink, so it can find its pipeline scripts and default config.

## 6. Check image access and server setup

Run:

```bash
biogemt doctor
```

The doctor checks that Docker is installed and reachable, the configured paths are accessible, and the pipeline image is available locally or can be resolved from GHCR.

If the image is public, Docker can download it without login. If GHCR reports `unauthorized`, either make the package public or have each user authenticate with an account/token that has package read access:

```bash
docker login ghcr.io
```

Resolve any `[FAIL]` messages before telling users the server is ready. A missing data directory is reported as a warning; create it if users need shared references.

## 7. Hand off to users

Tell users:

- Run `biogemt doctor` if Docker or image access fails.
- Work from a directory containing the input files and where they want output files. The launcher mounts that current directory read-write.
- Store shared reference data under `BIOGEMT_DATA`; the launcher mounts it read-only.
- Follow the [two-step annotation example](../README.md#run-an-annotation) to run `annotate` and then `summarize-sites`.
