SHELL := /usr/bin/env bash

.PHONY: help install deploy update activate rollback run

help:
	@echo "BioGeMT Pipelines"
	@echo ""
	@echo "Usage:"
	@echo "  make install RELEASE=v0.1.0    Install and activate a release"
	@echo "  make deploy RELEASE=v0.2.0     Install/test and activate a release"
	@echo "  make rollback RELEASE=v0.1.0   Activate an already installed release"
	@echo "  make run ARGS='--help'         Run the active release"

install:
	@test -n "$(RELEASE)" || { echo "RELEASE is required, e.g. make install RELEASE=v0.1.0" >&2; exit 1; }
	./scripts/install.sh "$(RELEASE)"

deploy update:
	@test -n "$(RELEASE)" || { echo "RELEASE is required, e.g. make deploy RELEASE=v0.2.0" >&2; exit 1; }
	./scripts/update.sh "$(RELEASE)"

activate rollback:
	@test -n "$(RELEASE)" || { echo "RELEASE is required, e.g. make rollback RELEASE=v0.1.0" >&2; exit 1; }
	./scripts/activate.sh "$(RELEASE)"

run:
	./scripts/run.sh $(ARGS)
