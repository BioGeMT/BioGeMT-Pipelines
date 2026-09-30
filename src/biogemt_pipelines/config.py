from __future__ import annotations

import os
from pathlib import Path
from typing import Any

import yaml

from .models import Pipeline, ReleasePolicy, ServerConfig


REPO_ROOT = Path(__file__).resolve().parents[2]
PIPELINES_DIR = REPO_ROOT / "pipelines"
DEFAULT_SERVER_CONFIG = REPO_ROOT / "config" / "server.yaml"


def load_server_config(config_path: Path | None = None) -> ServerConfig:
    root = Path(os.environ.get("BIOGEMT_ROOT", "/srv/biogemt"))
    config_file = config_path or DEFAULT_SERVER_CONFIG

    data: dict[str, Any] = {}
    if config_file.exists():
        loaded = yaml.safe_load(config_file.read_text()) or {}
        if not isinstance(loaded, dict):
            raise ValueError(f"Server config must be a mapping: {config_file}")
        data = loaded

    root = Path(str(data.get("root", root))).expanduser()
    server = ServerConfig.from_root(root)

    return ServerConfig(
        root=root,
        pipelines_dir=Path(str(data.get("pipelines_dir", server.pipelines_dir))).expanduser(),
        data_dir=Path(str(data.get("data_dir", server.data_dir))).expanduser(),
        runs_dir=Path(str(data.get("runs_dir", server.runs_dir))).expanduser(),
        logs_dir=Path(str(data.get("logs_dir", server.logs_dir))).expanduser(),
    )


def load_pipeline(path: Path) -> Pipeline:
    loaded = yaml.safe_load(path.read_text()) or {}
    if not isinstance(loaded, dict):
        raise ValueError(f"Pipeline definition must be a mapping: {path}")

    release_policy = loaded.get("release_policy") or {}
    if not isinstance(release_policy, dict):
        raise ValueError(f"release_policy must be a mapping: {path}")

    return Pipeline(
        name=_required_string(loaded, "name", path),
        repository=_required_string(loaded, "repository", path),
        runtime=_required_string(loaded, "runtime", path),
        command=_required_string(loaded, "command", path),
        test_command=str(loaded.get("test_command", "pytest")),
        release_policy=ReleasePolicy(
            required=bool(release_policy.get("required", True)),
            tag_pattern=str(release_policy.get("tag_pattern", r"^v[0-9]+\.[0-9]+\.[0-9]+$")),
        ),
    )


def load_pipelines() -> dict[str, Pipeline]:
    pipelines: dict[str, Pipeline] = {}
    for path in sorted(PIPELINES_DIR.glob("*.yaml")):
        pipeline = load_pipeline(path)
        if pipeline.name in pipelines:
            raise ValueError(f"Duplicate pipeline name: {pipeline.name}")
        pipelines[pipeline.name] = pipeline
    return pipelines


def get_pipeline(name: str) -> Pipeline:
    pipelines = load_pipelines()
    try:
        return pipelines[name]
    except KeyError as exc:
        available = ", ".join(sorted(pipelines)) or "none"
        raise ValueError(f"Unknown pipeline: {name}. Available pipelines: {available}") from exc


def _required_string(data: dict[str, Any], key: str, path: Path) -> str:
    value = data.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"Missing required string field '{key}' in {path}")
    return value
