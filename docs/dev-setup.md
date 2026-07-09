<!--
SPDX-License-Identifier: CC-BY-4.0
Copyright (c) 2026 openCCR contributors
-->

# Developer Setup

All `flutter` and `dart` commands run **inside the OCI container**. The host needs only:

- **Podman** ≥ 4.0 (preferred) or Docker
- **make**
- **git**

No Flutter SDK on the host. No Dart on the host.

## Flutter / Tool Versions (pinned in container)

| Tool | Version |
|------|---------|
| Flutter | 3.35.5 |
| Dart | 3.9.2 (bundled) |
| Android SDK | 34 |
| Java | 17 |

---

## Quick Start

```bash
# 1a. Pull the build image from ghcr.io (once the CI has pushed it)
make image-pull

# 1b. OR build the image locally from Containerfile (before ghcr.io push exists)
make image-build

# 2. Run the full quality gate
make check

# 3. Build Android APK
make build-apk
```

---

## Available Make Targets

```
make help              Show all targets
make image-build       Build OCI image locally from Containerfile
make image-pull        Pull / update the build image from ghcr.io

make check             Quality gate: format-check + analyze + test (single container run)
make format            Format code in-place
make format-check      Check formatting (exits 1 if diff)
make analyze           flutter analyze --fatal-infos
make test              flutter test

make build-apk         flutter build apk --debug
make build-appbundle   flutter build appbundle --debug
make build-linux       flutter build linux --debug

make shell             Interactive container shell (for debugging)
```

Override runtime or image:

```bash
make test RUNTIME=docker
make build-apk IMAGE=ghcr.io/openccr/companion-app:sha-abc123
```

SELinux systems (Fedora, RHEL) — append `:Z` to volume mounts:

```bash
make check SELINUX_Z=:Z
```

---

## Interactive Shell

Drop into a container shell with the repo mounted read-write:

```bash
make shell
# Inside container:
flutter pub get
flutter test --name "HomeScreen"
```

---

## iOS, macOS, Windows Builds

These **cannot run in the container** — Apple and Microsoft tools require native
runners. Run on the appropriate native host:

```bash
flutter build ios --debug --no-codesign      # macOS only
flutter build macos --debug                  # macOS only
flutter build windows --debug                # Windows only
```

In CI these use `macos-latest` and `windows-latest` runners (see `.github/workflows/ci.yml`).

---

## CI Bootstrap Sequence (first run)

The `ci.yml` pipeline needs the container image to exist in ghcr.io before it
can run the containerised jobs.

1. Commit and push all files (including `Containerfile` + `container.yml`)
2. Trigger the container build workflow:
   ```bash
   gh workflow run container.yml --ref main -f push=true
   ```
3. Wait for image at `ghcr.io/openccr/companion-app:flutter-3.35.5`
4. Push to main or open a PR — `ci.yml` succeeds

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `make: command not found` | Install make: `choco install make` (Windows), `brew install make` (macOS), `apt install make` (Ubuntu) |
| `podman: command not found` | Install Podman or set `RUNTIME=docker` |
| Container image not found | Run `make image-pull` or bootstrap sequence above |
| Permission denied on volume | Add `:Z` flag on SELinux hosts |
| Windows path issues in `-v` | Run from Git Bash, not PowerShell |
