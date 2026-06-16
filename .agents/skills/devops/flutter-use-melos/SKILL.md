---
name: flutter-use-melos
description: Manage multi-package Flutter projects using Melos and Dart Pub Workspaces. Use for monorepos requiring shared dependency resolution, automated versioning, and cross-package scripting.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 16 Jun 2024 12:00:00 GMT
---
# Multi-Package Management with Melos

## Contents
- [Prerequisites](#prerequisites)
- [Workspace Configuration (Melos 7+)](#workspace-configuration-melos-7)
- [Centralizing Dependency Versions](#centralizing-dependency-versions)
- [Package Configuration](#package-configuration)
- [Melos Scripts & Automation](#melos-scripts--automation)
- [Workflow](#workflow)
- [Common Commands](#common-commands)

## Prerequisites

- **Flutter SDK:** 3.44+ (or Dart 3.11+ for glob workspace support).
- **Melos:** Install globally or add as a dev dependency (recommended for CI).

```bash
dart pub global activate melos
```

## Workspace Configuration (Melos 7+)

Melos 7+ integrates natively with Dart Pub Workspaces. Configuration is split between `pubspec.yaml` (for native workspace and scripts) and `melos.yaml` (for Melos-specific features like version centralization).

```yaml
# root pubspec.yaml
name: my_monorepo
publish_to: none

environment:
  sdk: '>=3.11.0 <4.0.0'

workspace:
  - packages/*

dev_dependencies:
  melos: ^7.3.0

melos:
  scripts:
    # Define scripts here so they are discoverable by 'melos run'
    test:
      run: melos exec --dir-exists="test" -- "flutter test"
```

## Centralizing Dependency Versions

Use `melos.yaml` to centralize dependency versions across all packages.

```yaml
# melos.yaml
name: my_monorepo
packages:
  - packages/*

command:
  bootstrap:
    dependencies:
      dio: ^5.0.0
      flutter_bloc: ^8.1.0
    devDependencies:
      build_runner: any
```

When you run `melos bootstrap`, Melos will ensure all packages use the versions defined here, preventing version mismatch.

## Package Configuration

Each member package must opt into the workspace resolution.

```yaml
# packages/core_logic/pubspec.yaml
name: core_logic
version: 1.0.0

environment:
  sdk: '>=3.11.0 <4.0.0'

resolution: workspace # Essential for native workspace support

dependencies:
  # Use 'any' or a matching constraint; melos bootstrap will manage this.
  dio: any 
```

## Melos Scripts & Automation

Define scripts in the root `pubspec.yaml` (under `melos:`) to make them runable via `melos run`.

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
- [x] **Step 1: Setup Workspace.** Define `workspace:` in the root `pubspec.yaml` and create `melos.yaml`.
- [x] **Step 2: Initialize Packages.** Create sub-packages in the defined workspace directories.
- [x] **Step 3: Enable Resolution.** Set `resolution: workspace` in all sub-package `pubspec.yaml` files.
- [x] **Step 4: Centralize Versions.** Add common dependencies to `melos.yaml` under `command/bootstrap`.
- [x] **Step 5: Bootstrap.** Run `melos bootstrap` to link packages and sync dependency versions.
- [x] **Step 6: Define Scripts.** Add common tasks (build, test, lint) to the `melos:` section in `pubspec.yaml`.

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
