from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .config import get_pipeline, load_pipelines, load_server_config
from .deploy import DeploymentError, activate_release, current_release, install_release, run_pipeline, validate_release
from .models import PipelinePaths


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="biogemt-pipelines")
    parser.add_argument("--config", type=Path, help="Path to server YAML config")

    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("list", help="List registered pipelines")

    info = subparsers.add_parser("info", help="Show pipeline deployment info")
    info.add_argument("pipeline")

    deploy = subparsers.add_parser("deploy", help="Deploy a tested release")
    deploy.add_argument("pipeline")
    deploy.add_argument("--release", required=True)

    activate = subparsers.add_parser("activate", help="Switch to a previously deployed release")
    activate.add_argument("pipeline")
    activate.add_argument("--release", required=True)

    rollback = subparsers.add_parser("rollback", help="Switch back to a previous release")
    rollback.add_argument("pipeline")
    rollback.add_argument("--release", required=True)

    run = subparsers.add_parser("run", help="Run the active pipeline")
    run.add_argument("pipeline")
    run.add_argument("args", nargs=argparse.REMAINDER)

    doctor = subparsers.add_parser("doctor", help="Validate pipeline registry and release policies")
    doctor.add_argument("--release", help="Optional release tag to validate for every pipeline")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        server = load_server_config(args.config)

        if args.command == "list":
            for pipeline in sorted(load_pipelines().values(), key=lambda item: item.name):
                summary = f" - {pipeline.description}" if pipeline.description else ""
                print(f"{pipeline.name}: {pipeline.display_name}{summary}")
            return 0

        if args.command == "doctor":
            pipelines = load_pipelines()
            for pipeline in pipelines.values():
                if args.release:
                    validate_release(pipeline, args.release)
                print(f"ok {pipeline.name}")
            return 0

        pipeline = get_pipeline(args.pipeline)

        if args.command == "info":
            paths = PipelinePaths.for_pipeline(server, pipeline)
            print(f"name: {pipeline.name}")
            print(f"display_name: {pipeline.display_name}")
            if pipeline.description:
                print(f"description: {pipeline.description}")
            if pipeline.keywords:
                print(f"keywords: {', '.join(pipeline.keywords)}")
            if pipeline.use_cases:
                print("use_cases:")
                for use_case in pipeline.use_cases:
                    print(f"  - {use_case}")
            if pipeline.example_args:
                print(f"example: make run PIPELINE={pipeline.name} ARGS='-- {' '.join(pipeline.example_args)}'")
            print(f"repository: {pipeline.repository}")
            print(f"runtime: {pipeline.runtime}")
            print(f"command: {pipeline.command}")
            print(f"release_pattern: {pipeline.release_policy.tag_pattern}")
            print(f"current_release: {current_release(pipeline, server) or 'none'}")
            print(f"base_dir: {paths.base_dir}")
            return 0

        if args.command == "deploy":
            install_release(pipeline, server, args.release, run_tests=True)
            return 0

        if args.command in {"activate", "rollback"}:
            activate_release(pipeline, server, args.release)
            return 0

        if args.command == "run":
            pipeline_args = args.args
            if pipeline_args and pipeline_args[0] == "--":
                pipeline_args = pipeline_args[1:]
            return run_pipeline(pipeline, server, pipeline_args)

        parser.error(f"Unhandled command: {args.command}")
        return 2
    except (DeploymentError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
