from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class ReleasePolicy:
    required: bool
    tag_pattern: str


@dataclass(frozen=True)
class Pipeline:
    name: str
    display_name: str
    description: str
    responsible: str
    keywords: tuple[str, ...]
    use_cases: tuple[str, ...]
    input_formats: tuple[str, ...]
    output_formats: tuple[str, ...]
    result_files: tuple[str, ...]
    example_args: tuple[str, ...]
    visualization_ready: bool
    repository: str
    runtime: str
    command: str
    release_policy: ReleasePolicy
    test_command: str = "pytest"


@dataclass(frozen=True)
class ServerConfig:
    root: Path
    pipelines_dir: Path
    data_dir: Path
    runs_dir: Path
    logs_dir: Path

    @classmethod
    def from_root(cls, root: Path) -> "ServerConfig":
        return cls(
            root=root,
            pipelines_dir=root / "pipelines",
            data_dir=root / "data",
            runs_dir=root / "runs",
            logs_dir=root / "logs",
        )


@dataclass(frozen=True)
class PipelinePaths:
    base_dir: Path
    releases_dir: Path
    current_link: Path
    data_dir: Path
    runs_dir: Path
    logs_dir: Path

    @classmethod
    def for_pipeline(cls, server: ServerConfig, pipeline: Pipeline) -> "PipelinePaths":
        base_dir = server.pipelines_dir / pipeline.name
        return cls(
            base_dir=base_dir,
            releases_dir=base_dir / "releases",
            current_link=base_dir / "current",
            data_dir=server.data_dir,
            runs_dir=server.runs_dir / pipeline.name,
            logs_dir=server.logs_dir / pipeline.name,
        )
