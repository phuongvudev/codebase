---
name: flutter-scan-codebase-sitemap
description: Recursively scans the codebase to generate and store a sitemap artifact for rapid context retrieval and architectural understanding.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Mon, 16 Jun 2026 00:00:00 GMT
---
# Codebase Sitemap & Indexing Workflow

This skill is used to build a high-level "map" of the project. It scans the core directories (`lib/`, `test/`, `packages/`) to identify features, dependencies, and architectural patterns. The output is stored in `sitemap.artifact.md`.

## Workflow

### Step 1: Directory Discovery
Run `list_files` on key root directories to identify the project scope:
- `lib/src/features/`
- `lib/src/core/`
- `packages/` (if multi-package)
- `test/`

### Step 2: Feature Mapping
For each feature identified in `lib/src/features/`, list its internal structure:
- `domain/` (entities, repository interfaces)
- `data/` (DTOs, repository implementations, APIs)
- `presentation/` (BLoCs, screens, widgets)

### Step 3: Dependency Indexing
Search for core dependency registration sites:
- `get_it` registrations (usually in `injection.dart` or `dependencies.dart`).
- `go_router` modules.
- `retrofit` API clients.

### Step 4: Generate Sitemap Artifact
Create or update `/Volumes/Data/workstation/personal/projects/flutter/codebase/.artifacts/sitemap.artifact.md` with the following structure:

```markdown
# Codebase Sitemap

## 🏗️ Core Architecture
- **Injection**: [path/to/injection.dart]
- **Routing**: [path/to/router.dart]
- **Theme**: [path/to/theme.dart]
- **Network**: [path/to/network.dart]
- **Base Classes**: [path/to/base_classes/]
- **Utilities**: [path/to/utils/]

## 🚀 Features
### [Feature Name]
- **Domain**: [path/to/domain]
- **Data**: [path/to/data]
- **Presentation**: [path/to/presentation]
- **Widgets**: [path/to/widgets]

## 📦 Packages
- **[Package Name]**: [path/to/package]

## 🧪 Testing Scope
- **Unit Tests**: `test/unit`
- **Widget Tests**: `test/widget`
- **Integration Tests**: `integration_test/`
```

## When to Use
- At the start of a large task to "warm up" your memory.
- After significant refactoring or adding multiple features.
- When asked to "explain the project structure".
- 
