from __future__ import annotations

import os
import re
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path

from .models import Pipeline, PipelinePaths, ServerConfig


class DeploymentError(RuntimeError):
    pass


def require_supported_runtime(pipeline: Pipeline) -> None:
    if pipeline.runtime != "uv":
        raise DeploymentError(f"Unsupported runtime for {pipeline.name}: {pipeline.runtime}")


def validate_release(pipeline: Pipeline, release: str) -> None:
    if pipeline.release_policy.required and not re.fullmatch(pipeline.release_policy.tag_pattern, release):
        raise DeploymentError(
            f"Invalid release '{release}' for {pipeline.name}. "
            f"Expected tag pattern: {pipeline.release_policy.tag_pattern}"
        )


def ensure_layout(paths: PipelinePaths) -> None:
    for directory in [paths.releases_dir, paths.data_dir, paths.runs_dir, paths.logs_dir]:
        directory.mkdir(parents=True, exist_ok=True)


def release_dir(paths: PipelinePaths, release: str) -> Path:
    safe_release = re.sub(r"[^A-Za-z0-9._-]", "_", release)
    return paths.releases_dir / safe_release


def install_release(pipeline: Pipeline, server: ServerConfig, release: str, *, run_tests: bool) -> Path:
    require_supported_runtime(pipeline)
    validate_release(pipeline, release)
    paths = PipelinePaths.for_pipeline(server, pipeline)
    ensure_layout(paths)

    target = release_dir(paths, release)
    if target.joinpath(".git").is_dir():
        print(f"Release {release} is already installed at {target}")
    else:
        run(["git", "clone", pipeline.repository, str(target)])

    run(["git", "fetch", "--tags"], cwd=target)
    run(["git", "checkout", release], cwd=target)
    require_clean_worktree(target, release)
    run(["uv", "sync", "--frozen"], cwd=target)

    if run_tests:
        run(["uv", "run", *shlex.split(pipeline.test_command)], cwd=target)

    activate_release(pipeline, server, release)
    return target


def activate_release(pipeline: Pipeline, server: ServerConfig, release: str) -> Path:
    validate_release(pipeline, release)
    paths = PipelinePaths.for_pipeline(server, pipeline)
    target = release_dir(paths, release)

    if not target.joinpath(".git").is_dir():
        raise DeploymentError(f"Release {release} is not installed at {target}")

    paths.current_link.parent.mkdir(parents=True, exist_ok=True)
    tmp_link = paths.current_link.with_name(f".{paths.current_link.name}.tmp")
    if tmp_link.exists() or tmp_link.is_symlink():
        tmp_link.unlink()
    tmp_link.symlink_to(target)
    tmp_link.replace(paths.current_link)

    print(f"Activated {pipeline.name} release {release}")
    print(f"Current release: {paths.current_link} -> {target}")
    return target


def run_pipeline(pipeline: Pipeline, server: ServerConfig, args: list[str], *, run_id: str | None = None) -> int:
    require_supported_runtime(pipeline)
    paths = PipelinePaths.for_pipeline(server, pipeline)
    current = paths.current_link

    if not current.joinpath(".git").is_dir():
        raise DeploymentError(f"Pipeline is not installed at {current}")

    run_id = run_id or default_run_id()
    run_dir = paths.runs_dir / run_id
    output_dir = run_dir / "output"
    log_dir = run_dir / "logs"
    tmp_dir = run_dir / "tmp"

    for directory in [output_dir, log_dir, tmp_dir]:
        directory.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env.update(
        {
            "BIOGEMT_DATA_DIR": str(paths.data_dir),
            "BIOGEMT_RUNS_DIR": str(paths.runs_dir),
            "BIOGEMT_RUN_ID": run_id,
            "BIOGEMT_RUN_DIR": str(run_dir),
            "BIOGEMT_OUTPUT_DIR": str(output_dir),
            "BIOGEMT_LOGS_DIR": str(paths.logs_dir),
            "BIOGEMT_LOG_DIR": str(log_dir),
            "BIOGEMT_TMP_DIR": str(tmp_dir),
        }
    )
    completed = subprocess.run(["uv", "run", pipeline.command, *args], cwd=current, env=env, check=False)
    return completed.returncode


def default_run_id() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def current_release(pipeline: Pipeline, server: ServerConfig) -> str | None:
    paths = PipelinePaths.for_pipeline(server, pipeline)
    if not paths.current_link.is_symlink():
        return None
    target = paths.current_link.resolve()
    try:
        return target.relative_to(paths.releases_dir.resolve()).as_posix()
    except ValueError:
        return str(target)


def require_clean_worktree(path: Path, release: str) -> None:
    completed = run(["git", "status", "--porcelain"], cwd=path, capture=True)
    if completed.stdout.strip():
        raise DeploymentError(f"Refusing to activate {release}; local changes exist in {path}")


def run(command: list[str], *, cwd: Path | None = None, capture: bool = False) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            command,
            cwd=cwd,
            check=True,
            text=True,
            stdout=subprocess.PIPE if capture else None,
            stderr=subprocess.PIPE if capture else None,
        )
    except FileNotFoundError as exc:
        raise DeploymentError(f"Required command not found: {command[0]}") from exc
    except subprocess.CalledProcessError as exc:
        if capture and exc.stderr:
            raise DeploymentError(exc.stderr.strip()) from exc
        raise DeploymentError(f"Command failed: {' '.join(command)}") from exc
