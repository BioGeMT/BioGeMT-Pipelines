SHELL := /usr/bin/env bash
PIPELINE ?= genomic_region_annotator

.PHONY: help list info status deploy update activate rollback run doctor

help:
	@echo "BioGeMT Pipelines"
	@echo ""
	@echo "Usage:"
	@echo "  make list                              Browse available pipelines"
	@echo "  make status                            Show active pipeline releases"
	@echo "  make run ARGS='-- --help'              Run the active pipeline"
	@echo "  make deploy RELEASE=v0.2.0             Admin: deploy a tested release"
	@echo "  make rollback RELEASE=v0.1.0           Admin: switch to previous release"
	@echo "  make info PIPELINE=$(PIPELINE)          Show pipeline details"
	@echo ""
	@echo "Defaults:"
	@echo "  PIPELINE=$(PIPELINE)"

list:
	uv run biogemt-pipelines list

info:
	uv run biogemt-pipelines info "$(PIPELINE)"

status:
	uv run biogemt-pipelines status

deploy update:
	@test -n "$(RELEASE)" || { echo "RELEASE is required, e.g. make deploy RELEASE=v0.2.0" >&2; exit 1; }
	uv run biogemt-pipelines deploy "$(PIPELINE)" --release "$(RELEASE)"

activate rollback:
	@test -n "$(RELEASE)" || { echo "RELEASE is required, e.g. make rollback RELEASE=v0.1.0" >&2; exit 1; }
	uv run biogemt-pipelines rollback "$(PIPELINE)" --release "$(RELEASE)"

run:
	uv run biogemt-pipelines run "$(PIPELINE)" $(ARGS)

doctor:
	uv run biogemt-pipelines doctor
