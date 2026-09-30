SHELL := /usr/bin/env bash
PIPELINE ?= genomic_region_annotator

.PHONY: help list info install deploy update activate rollback run doctor

help:
	@echo "BioGeMT Pipelines"
	@echo ""
	@echo "Usage:"
	@echo "  make list                              List registered pipelines"
	@echo "  make info PIPELINE=$(PIPELINE)          Show pipeline deployment info"
	@echo "  make install RELEASE=v0.1.0            Install and activate without tests"
	@echo "  make deploy RELEASE=v0.2.0             Install/test and activate release"
	@echo "  make rollback RELEASE=v0.1.0           Activate an installed release"
	@echo "  make run ARGS='-- --help'              Run the active release"
	@echo ""
	@echo "Defaults:"
	@echo "  PIPELINE=$(PIPELINE)"

list:
	uv run biogemt-pipelines list

info:
	uv run biogemt-pipelines info "$(PIPELINE)"

install:
	@test -n "$(RELEASE)" || { echo "RELEASE is required, e.g. make install RELEASE=v0.1.0" >&2; exit 1; }
	uv run biogemt-pipelines install "$(PIPELINE)" --release "$(RELEASE)"

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
