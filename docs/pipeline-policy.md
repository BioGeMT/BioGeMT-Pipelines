# Pipeline Policy

This repository only deploys pipelines that publish explicit releases.

## Mandatory release rule

Every pipeline integrated into BioGeMT Pipelines must provide versioned release tags before it can be deployed on shared infrastructure.

Accepted release tags must match:

```text
vMAJOR.MINOR.PATCH
```

Examples:

```text
v0.1.0
v1.2.3
```

Branch names such as `main`, `dev`, or `latest` are not valid production deployment targets.

## Required pipeline repository state

Before a pipeline is added here, its source repository must have:

1. A GitHub release or Git tag matching `vMAJOR.MINOR.PATCH`.
2. A lockfile or equivalent reproducible dependency definition.
3. A documented command-line entrypoint.
4. A minimal test suite that can run during deployment.

## Deployment rule

Deployment commands must receive a release tag explicitly:

```bash
make deploy RELEASE=v0.1.0
```

Deploying directly from a moving branch is intentionally unsupported.
