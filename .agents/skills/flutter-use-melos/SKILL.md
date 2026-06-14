---
name: flutter-use-melos
description: Manage multi-package Flutter projects using Melos and Dart Pub Workspaces. Use for monorepos requiring shared dependency resolution, automated versioning, and cross-package scripting.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 12:00:00 GMT
---
# Multi-Package Management with Melos

## Contents
- [Prerequisites](#prerequisites)
- [Workspace Configuration (Melos 7+)](#workspace-configuration-melos-7)
- [Package Configuration](#package-configuration)
- [Melos Scripts & Automation](#melos-scripts--automation)
- [Workflow](#workflow)
- [Common Commands](#common-commands)

## Prerequisites

- **Flutter SDK:** 3.38+ (or Dart 3.10+).
- **Melos:** Install globally or add as a dev dependency (recommended for CI).

```bash
dart pub global activate melos
```

## Workspace Configuration (Melos 7+)

Melos 7+ integrates natively with Dart Pub Workspaces. The configuration lives primarily in the root `pubspec.yaml`.

```yaml
# root pubspec.yaml
name: my_monorepo
publish_to: none

environment:
  sdk: '>=3.10.0 <4.0.0'

workspace:
  - apps/*
  - packages/*

dev_dependencies:
  melos: ^7.3.0

melos:
  name: my_monorepo
```

## Package Configuration

Each member package must opt into the workspace resolution.

```yaml
# packages/core_logic/pubspec.yaml
name: core_logic
version: 1.0.0

environment:
  sdk: '>=3.10.0 <4.0.0'

resolution: workspace # Essential for local path resolution without overrides
```

## Melos Scripts & Automation

Define scripts in the root `pubspec.yaml` (under `melos:`) or `melos.yaml`. Use filters to optimize execution.

```yaml
melos:
  scripts:
    generate:
      run: melos exec --depends-on="build_runner" -- "dart run build_runner build --delete-conflicting-outputs"
      description: Run code generation for relevant packages.

    test:
      run: melos exec --dir-exists="test" -- "flutter test"
      description: Run tests in packages that have a test folder.

    analyze:
      run: melos exec -- "flutter analyze"
      description: Run static analysis across all packages.
```

## Workflow

### Task Progress
- [ ] **Step 1: Setup Workspace.** Define `workspace:` and `melos:` in the root `pubspec.yaml`.
- [ ] **Step 2: Initialize Packages.** Create sub-packages in the defined workspace directories.
- [ ] **Step 3: Enable Resolution.** Set `resolution: workspace` in all sub-package `pubspec.yaml` files.
- [ ] **Step 4: Bootstrap.** Run `melos bootstrap` to link packages and install dependencies.
- [ ] **Step 5: Define Scripts.** Add common tasks (build, test, lint) to the `melos:` section.
- [ ] **Step 6: CI/CD.** Configure Melos in your CI environment for automated checks and publishing.

## Common Commands

| Command | Description |
| :--- | :--- |
| `melos bootstrap` | Resolves dependencies and links local packages together. |
| `melos clean` | Removes temporary build files and `.dart_tool` folders. |
| `melos exec -- <command>` | Runs a command in every package. |
| `melos run <script>` | Runs a script defined in `melos.scripts`. |
| `melos list` | Lists all packages in the workspace and their relationships. |
| `melos version` | Bumps versions based on Conventional Commits. |

### Powerful Filtering Examples
- `melos exec --scope="*ui*" -- flutter test`: Run tests only on UI-related packages.
- `melos exec --ignore="*example*" -- flutter analyze`: Analyze everything except example apps.
- `melos exec --depends-on="dio" -- ...`: Run command only in packages that use `dio`.
