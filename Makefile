# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 openCCR contributors
#
# Container-first build system.
# All flutter/dart commands run inside the OCI container — never on the host.
#
# Prerequisites:
#   - podman (or docker; set RUNTIME=docker)
#   - Container image pulled OR built locally:
#       make image-pull              # pull from ghcr.io
#       make image-build             # build locally from Containerfile
#
# SELinux (Fedora/RHEL): add :Z to volume mounts
#   make test SELINUX_Z=:Z
#
# Quick start:
#   make image-build  # first time, before ghcr.io image exists
#   make check        # quality gate (format + analyze + test)
#   make build-apk    # Android APK

IMAGE     ?= ghcr.io/openccr/companion-app:flutter-3.35.5
RUNTIME   ?= podman
SELINUX_Z ?=

# MSYS_NO_PATHCONV=1 prevents Git Bash on Windows from converting
# container-internal paths (e.g. /workspace) to Windows paths.
export MSYS_NO_PATHCONV = 1

_VOL    = -v "$(CURDIR)":/workspace$(SELINUX_Z)
_RUN    = $(RUNTIME) run --rm $(_VOL) -w /workspace $(IMAGE)
_RUNIT  = $(RUNTIME) run --rm -it $(_VOL) -w /workspace $(IMAGE)

# Each target runs pub get and the command in a single container invocation
# so that the pub cache (in-container ephemeral) is shared across both steps.
_PUB    = flutter pub get

.DEFAULT_GOAL := help

.PHONY: help image-pull image-build format format-check analyze test check \
        build-apk build-appbundle build-linux shell

help:
	@printf "openCCR companion — container-first targets\n\n"
	@printf "  Setup\n"
	@printf "    make image-build       Build OCI image locally from Containerfile\n"
	@printf "    make image-pull        Pull/update build image from ghcr.io\n"
	@printf "\n"
	@printf "  Quality gate\n"
	@printf "    make check             format-check + analyze + test (use before commit)\n"
	@printf "    make format            Format code in-place\n"
	@printf "    make format-check      Check formatting (exit 1 if diff)\n"
	@printf "    make analyze           flutter analyze --fatal-infos\n"
	@printf "    make test              flutter test\n"
	@printf "\n"
	@printf "  Builds (container)\n"
	@printf "    make build-apk         flutter build apk --debug\n"
	@printf "    make build-appbundle   flutter build appbundle --debug\n"
	@printf "    make build-linux       flutter build linux --debug\n"
	@printf "\n"
	@printf "  Utility\n"
	@printf "    make shell             Interactive container shell\n"
	@printf "\n"
	@printf "  iOS / macOS / Windows: must build on native host (Apple / MS restriction)\n"
	@printf "    flutter build ios --debug --no-codesign\n"
	@printf "    flutter build macos --debug\n"
	@printf "    flutter build windows --debug\n"
	@printf "\n"
	@printf "  IMAGE=$(IMAGE)\n"
	@printf "  RUNTIME=$(RUNTIME)\n"

image-build:
	$(RUNTIME) build -t $(IMAGE) -f Containerfile .

image-pull:
	$(RUNTIME) pull $(IMAGE)

format:
	$(_RUN) bash -c "$(_PUB) && dart format lib/ test/"

format-check:
	$(_RUN) bash -c "$(_PUB) && dart format --set-exit-if-changed lib/ test/"

analyze:
	$(_RUN) bash -c "$(_PUB) && flutter analyze --fatal-infos"

test:
	$(_RUN) bash -c "$(_PUB) && flutter test"

check:
	$(_RUN) bash -c "$(_PUB) && dart format --set-exit-if-changed lib/ test/ && flutter analyze --fatal-infos && flutter test"

build-apk:
	$(_RUN) bash -c "$(_PUB) && flutter build apk --debug"

build-appbundle:
	$(_RUN) bash -c "$(_PUB) && flutter build appbundle --debug"

build-linux:
	$(_RUN) bash -c "$(_PUB) && flutter build linux --debug"

shell:
	$(_RUNIT) bash
