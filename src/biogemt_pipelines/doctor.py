from __future__ import annotations

import shutil
from dataclasses import dataclass

from .deploy import current_release, validate_release
from .models import Pipeline, PipelinePaths, ServerConfig


@dataclass(frozen=True)
class CheckResult:
    status: str
    name: str
    message: str


def run_checks(pipelines: dict[str, Pipeline], server: ServerConfig, release: str | None = None) -> list[CheckResult]:
    results: list[CheckResult] = []

    for command in ["git", "uv"]:
        if shutil.which(command):
            results.append(CheckResult("ok", f"command:{command}", "available"))
        else:
            results.append(CheckResult("error", f"command:{command}", "not found in PATH"))

    if pipelines:
        results.append(CheckResult("ok", "registry", f"{len(pipelines)} pipeline(s) registered"))
    else:
        results.append(CheckResult("error", "registry", "no pipelines registered"))

    for pipeline in pipelines.values():
        try:
            if release:
                validate_release(pipeline, release)
            results.append(CheckResult("ok", f"pipeline:{pipeline.name}", "definition valid"))
        except Exception as exc:
            results.append(CheckResult("error", f"pipeline:{pipeline.name}", str(exc)))

        active = current_release(pipeline, server)
        if active:
            results.append(CheckResult("ok", f"active:{pipeline.name}", active))
        else:
            results.append(CheckResult("warn", f"active:{pipeline.name}", "not deployed"))

    for directory in [server.root, server.pipelines_dir, server.data_dir, server.runs_dir, server.logs_dir]:
        if directory.exists():
            results.append(CheckResult("ok", f"path:{directory}", "exists"))
        else:
            results.append(CheckResult("warn", f"path:{directory}", "does not exist yet"))

    for pipeline in pipelines.values():
        paths = PipelinePaths.for_pipeline(server, pipeline)
        if paths.current_link.exists() or paths.current_link.is_symlink():
            results.append(CheckResult("ok", f"current:{pipeline.name}", str(paths.current_link)))
        else:
            results.append(CheckResult("warn", f"current:{pipeline.name}", "current release link missing"))

    return results


def has_errors(results: list[CheckResult]) -> bool:
    return any(result.status == "error" for result in results)
