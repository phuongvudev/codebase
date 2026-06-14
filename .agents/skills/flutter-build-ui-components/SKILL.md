---
name: flutter-build-ui-components
description: Build scalable and performant UI components (screens and widgets) in Flutter using atomic design principles, composition, and modern layout APIs.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 20:00:00 GMT
---
# Building Screens and Widgets

## Contents
- [Recommended Folder Structure](#recommended-folder-structure)
- [Atomic Design Pattern](#atomic-design-pattern)
- [Modern Layout APIs](#modern-layout-apis)
- [Performance Best Practices](#performance-best-practices)
- [Composition & Reusability](#composition--reusability)
- [Advanced: Abstract Base Components](#advanced-abstract-base-components)
- [Accessibility (Semantics)](#accessibility-semantics)
- [Workflow](#workflow)
- [Examples](#examples)

## Recommended Folder Structure

Use a **Feature-Driven (Feature-First)** architecture to ensure scalability and modularity. This structure organizes code by business domain rather than technical type.

```text
lib/
├── main.dart
├── app.dart                  # Global providers, routing, and root widget
├── core/                     # Infrastructure and app-wide logic
│   ├── theme/                # Design system (AppTheme, Colors)
│   ├── network/              # API clients, interceptors
│   └── utils/                # Extensions, formatters, constants
├── shared/                   # UI components reused across features
│   ├── widgets/              # Common Atoms and Molecules
│   └── models/               # Shared domain entities
└── features/                 # Modular business features
    ├── user_profile/
    │   ├── data/             # Repositories and DataSources
    │   ├── domain/           # Business logic and entities
    │   └── presentation/     # BLoCs, Screens, and feature-specific widgets
    └── auth/
        ├── data/
        ├── domain/
        └── presentation/
```

### Directory Roles
- **core/**: Low-level logic that doesn't depend on features.
- **shared/**: Reusable UI elements (Buttons, TextStyles) that follow the design system.
- **features/**: Each folder is a self-contained module containing its own data, domain, and UI layers.

## Atomic Design Pattern

Break down your UI into hierarchical levels to ensure consistency and reusability.

1.  **Atoms**: Basic building blocks (e.g., `CustomButton`, `AppText`, `AppIcon`). They are stateless and rely only on passed parameters.
2.  **Molecules**: Simple groups of atoms (e.g., `SearchBar`, `ProfileHeader`). They handle simple local interactions.
3.  **Organisms**: Complex components formed by molecules and atoms (e.g., `UserCardList`, `Navbar`). They often fetch data or interact with global state.
4.  **Screens**: The top-level composition of organisms that represents a full page in the application.

## Modern Layout APIs

### 1. Granular Rebuilds with MediaQuery
Use `MediaQuery.sizeOf(context)` instead of `MediaQuery.of(context).size` to prevent unnecessary rebuilds when non-size media properties (like brightness) change.

```dart
final size = MediaQuery.sizeOf(context);
final isWide = size.width > 600;
```

### 2. LayoutBuilder
Use `LayoutBuilder` to make layout decisions based on the **parent's constraints** rather than the total screen size.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 400) {
      return Row(...);
    }
    return Column(...);
  },
)
```

## Performance Best Practices

-   **Const Constructors**: Use `const` religiously to allow Flutter to cache widget instances.
-   **RepaintBoundary**: Wrap complex animations or custom painters in a `RepaintBoundary` to isolate their repainting logic from the rest of the tree.
-   **Lazy Lists**: Always use `.builder` constructors for `ListView` and `GridView` to only render visible items.
-   **Atomic Widgets**: Keep widgets small and focused. Smaller widget trees are faster to build and easier for Flutter to optimize.

## Composition & Reusability

Favor **Composition** over Inheritance. Use parameters (like `Widget? child` or `List<Widget> actions`) to create flexible and reusable components.

```dart
class AppCard extends StatelessWidget {
  final Widget content;
  final List<Widget>? actions;

  const AppCard({required this.content, this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        content,
        if (actions != null) Row(children: actions!),
      ],
    );
  }
}
```

## Advanced: Abstract Base Components

Use abstract base classes to centralize responsiveness, reduce boilerplate, and optimize rebuilds when using BLoC.

### 1. BaseResponsiveScreen<B, S>
This base class handles BLoC provisioning and provides multi-layout support with performance-optimized rebuilds.

```dart
abstract class BaseResponsiveScreen<B extends Bloc<dynamic, S>, S> extends StatelessWidget {
  const BaseResponsiveScreen({super.key});

  /// Factory method to create the BLoC.
  B get bloc(BuildContext context);

  /// Optimization: Control when the UI should rebuild.
  bool buildWhen(S previous, S current) => previous != current;
  
  ///Optimization: Control when the UI should listen for state changes.
  bool listenWhen(S previous, S current) => previous != current;
  
  ///Listener for side effects (e.g., showing SnackBars on errors).
  void listener(BuildContext context, S state) {}
  
  ///Define the breakpoints and layouts for different screen sizes.
  double get tabletBreakpoint => 600.0;
  
  double get desktopBreakpoint => 1200.0;
  

  /// Adaptive layouts for different screen sizes.
  Widget buildSmallScreen(BuildContext context, S state);
  Widget buildMediumScreen(BuildContext context, S state) => buildSmallScreen(context, state);
  Widget buildLargeScreen(BuildContext context, S state) => buildMediumScreen(context, state);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: (context) => bloc(context),
      child: BlocConsumer<B, S>(
        listenWhen: listenWhen,
        buildWhen: buildWhen,
        listener: listener,
        builder: (context, state) {
          return ScreenBreakpointBuilder(
            smallBuilder: (context) => buildSmallScreen(context, state),
            mediumBuilder: (context) => buildMediumScreen(context, state),
            largeBuilder: (context) => buildLargeScreen(context, state),
          );
        },
      ),
    );
  }
  
  ///Optional: Common UI states for error, loading, and empty states.
  Widget buildError(BuildContext context, String message) {
    return Center(child: Text(message));
  }
  
  ///Optional: Common UI states for error, loading, and empty states.
  Widget buildLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  ///Optional: Common UI states for error, loading, and empty states.
  Widget buildEmpty(BuildContext context) {
    return const Center(child: Text('No data available'));
  }
  
  ///Optional: Common UI states for error, loading, and empty states.
  Widget buildPlaceholder(BuildContext context) {
    return const Center(child: Text('Something went wrong'));
  }

}
```

### 2. BaseResponsiveWidget
For reusable components that adapt to their parent container's size.

```dart
abstract class BaseResponsiveWidget extends StatelessWidget {
  const BaseResponsiveWidget({super.key});

  Widget buildSmall(BuildContext context);
  Widget buildLarge(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 400) return buildLarge(context);
        return buildSmall(context);
      },
    );
  }
}
```

###3. ScreenBreakpointBuilder
A helper widget to centralize breakpoint logic for screens.
```dart
class ScreenBreakpointBuilder extends StatelessWidget {
  final WidgetBuilder smallBuilder;
  final WidgetBuilder mediumBuilder;
  final WidgetBuilder largeBuilder;  
  
    const ScreenBreakpointBuilder({
        required this.smallBuilder,
        required this.mediumBuilder,
        required this.largeBuilder,
        super.key,
    });
    
    @override
    Widget build(BuildContext context) {
        final width = MediaQuery.sizeOf(context).width;
        if (width >= 1200) {
            return largeBuilder(context);
        } else if (width >= 600) {
            return mediumBuilder(context);
        } else {
            return smallBuilder(context);
        }
    }
``` 

## Accessibility (Semantics)

Ensure your UI is accessible by using `Semantics` widgets to provide meaningful labels for screen readers.

```dart
Semantics(
  label: 'Delete item',
  button: true,
  child: IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () => onDelete(),
  ),
)
```

## Workflow

### Task Progress
- [ ] **Step 1: Analyze Design.** Identify Atoms, Molecules, and Organisms.
- [ ] **Step 2: Build Atoms.** Create base stateless components.
- [ ] **Step 3: Implement Base Patterns.** Use `BaseResponsiveScreen` for new pages to centralize BLoC and responsiveness.
- [ ] **Step 4: Apply Optimizations.** Implement `buildWhen` in screens and use `MediaQuery.sizeOf`.
- [ ] **Step 5: Define Layouts.** Fill in `buildMobile`, `buildTablet`, and `buildDesktop`.
- [ ] **Step 6: Refine with Accessibility.** Add `Semantics` and test with screen readers.

## Examples

### Concrete Responsive Screen
```dart
class UserProfilePage extends BaseResponsiveScreen<UserBloc, BaseState<User>> {
  const UserProfilePage({super.key});

  @override
  UserBloc get bloc(BuildContext context) => getIt<UserBloc>();

  @override
  Widget buildMobile(BuildContext context, BaseState<User> state) {
    return switch (state) {
      SuccessState(data: var user) => MobileProfile(user: user),
      LoadingState() => const Center(child: CircularProgressIndicator()),
      _ => const ErrorPlaceholder(),
    };
  }

  @override
  Widget buildDesktop(BuildContext context, BaseState<User> state) {
    return switch (state) {
      SuccessState(data: var user) => DesktopProfile(user: user),
      _ => buildMobile(context, state),
    };
  }
}
```
