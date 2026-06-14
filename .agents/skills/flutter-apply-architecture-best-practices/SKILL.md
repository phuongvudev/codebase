---
name: flutter-apply-architecture-best-practices
description: Architects a Flutter application using a hybrid "Clean Architecture + Feature-First" approach. Use when structuring a new project or refactoring for scalability.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 21:00:00 GMT
---
# Flutter Architecture: Clean & Feature-First

## Contents
- [Architectural Philosophy](#architectural-philosophy)
- [Layer Responsibilities](#layer-responsibilities)
- [Suggested Folder Structure](#suggested-folder-structure)
- [What is Optional?](#what-is-optional)
- [Standard Implementation Workflow](#standard-implementation-workflow)
- [Best Practices by Skill](#best-practices-by-skill)

## Architectural Philosophy

For 2024-2025, the recommended architecture is a hybrid of **Clean Architecture** (for isolation of concerns) and **Feature-First** (for modular scalability). This approach ensures that business logic is decoupled from external dependencies and that the project remains easy to navigate as it grows.

## Layer Responsibilities

### 1. Presentation Layer (UI)
*   **Role**: Handles user interaction and displays data.
*   **Components**: Widgets, BLoCs/Cubit, and UI models.
*   **Rule**: Must not contain business logic. Uses `BaseResponsiveScreen` to handle responsiveness and BLoC lifecycle.

### 2. Domain Layer (Optional)
*   **Role**: The "Heart" of the application. Contains pure Dart code representing business rules.
*   **Components**: Entities, Use Cases, and Repository interfaces (contracts).
*   **Rule**: Must not depend on any other layer or external libraries (like `dio`).

### 3. Data Layer
*   **Role**: Handles data retrieval from external sources.
*   **Components**: Repository implementations, DataSources (API clients like Retrofit), and Models (DTOs).
*   **Rule**: Implements the Repository interfaces defined in the Domain layer.

## Suggested Folder Structure

```text
lib/
├── main.dart                 # Multi-flavor entry points (main_dev.dart, etc.)
├── app.dart                  # Root widget, routing, and global providers
├── core/                     # App-wide infrastructure
│   ├── config/               # AppConfig (GetIt singletons, dart-define)
│   ├── di/                   # Service locator setup (get_it)
│   ├── network/              # Dio configuration, interceptors
│   ├── theme/                # Design system (colors, text styles)
│   └── utils/                # Extensions, formatters, constants
├── shared/                   # UI reused across features (Atoms, Molecules)
│   └── widgets/              # PrimaryButton, AppTextField, etc.
└── features/                 # Modular business features
    └── user_profile/
        ├── data/             # Repositories, API clients, DTOs
        ├── domain/           # Entities, Repository Interfaces, Use Cases
        └── presentation/     # BLoCs, Screens, Feature-widgets
```

## What is Optional?

To avoid over-engineering, you can omit certain components for simple features:

*   **Use Cases**: If a feature is a simple CRUD operation that just calls a repository, you can call the repository directly from the BLoC. Only create Use Case classes when multiple repositories must be orchestrated or complex logic is involved.
*   **Entities vs Models**: If your API data structure matches your UI needs exactly, you can use the `JsonSerializable` models directly in the presentation layer. Only separate them into "Entities" if the data layer needs to differ significantly from the business logic.
*   **Domain Layer**: For very small projects or single-purpose apps, you can merge Domain into the Data layer.

## Standard Implementation Workflow

Follow this step-by-step guide to implement a new feature. Track progress with the checkboxes.

- [ ] **Step 1: Domain Definition (Contracts)**
  - Define entities in `features/<feature>/domain/entities/`.
  - Define repository interfaces in `features/<feature>/domain/repositories/`.
- [ ] **Step 2: Data Layer implementation**
  - Define DTO models with `json_serializable` in `features/<feature>/data/models/`.
  - Define Retrofit API clients in `features/<feature>/data/data_sources/`.
  - Implement repository interfaces in `features/<feature>/data/repositories/`.
- [ ] **Step 3: Dependency Injection**
  - Register API clients and repositories in `lib/core/di/injection.dart`.
  - Use `getIt.registerLazySingleton` for services and repositories.
- [ ] **Step 4: Business Logic (BLoC)**
  - Create the BLoC in `features/<feature>/presentation/bloc/`.
  - Use naming conventions: `EventName` (past tense) -> `_onEventName`.
  - Extend `BaseAppBloc` and use `handleOperation` for async logic.
- [ ] **Step 5: Internationalization**
  - Add required strings to `lib/l10n/app_en.arb`.
  - Run `dart run intl_utils:generate` to update the `S` class.
- [ ] **Step 6: UI Construction (Atomic Design)**
  - Build Atoms/Molecules in `shared/widgets/` or feature-specific folders.
  - Create the Screen extending `BaseResponsiveScreen` in `presentation/screens/`.
  - Implement `buildMobile`, `buildTablet`, and `buildDesktop`.
- [ ] **Step 7: Verification & Previews**
  - Add a `@Preview` to the new widgets/screens.
  - Implement a widget test using `WidgetTester`.
  - (Optional) Run `launch_app` via MCP to verify the final integration.

## Best Practices by Skill

*   **State Management**: Use **BLoC** for predictable state transitions. [Skill](file:///Volumes/Data/workstation/personal/projects/flutter/codebase/.agents/skills/flutter-use-bloc/SKILL.md)
*   **Dependency Injection**: Use **GetIt** with Constructor Injection. [Skill](file:///Volumes/Data/workstation/personal/projects/flutter/codebase/.agents/skills/flutter-use-get-it/SKILL.md)
*   **Networking**: Use **Dio + Retrofit** with Background Parsing for large payloads. [Skill](file:///Volumes/Data/workstation/personal/projects/flutter/codebase/.agents/skills/flutter-use-dio-retrofit/SKILL.md)
*   **UI Components**: Use **Atomic Design** and **Abstract Bases**. [Skill](file:///Volumes/Data/workstation/personal/projects/flutter/codebase/.agents/skills/flutter-build-ui-components/SKILL.md)
*   **Multi-Flavor**: Use **Environment Classes** and `dart-define`. [Skill](file:///Volumes/Data/workstation/personal/projects/flutter/codebase/.agents/skills/flutter-configure-multi-flavor/SKILL.md)
