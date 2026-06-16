---
name: flutter-add-widget-dynamic-state-widget-state
description: Build Flutter widgets with dynamic visual behavior using WidgetState and WidgetStateProperty. Use when creating interactive components that must react to pressed, hovered, focused, selected, disabled, and dragged states.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Sun, 14 Jun 2026 00:00:00 GMT
---
# Building Flutter Widgets with Dynamic State (WidgetState)

## Contents
- [When to Use](#when-to-use)
- [Core Concepts](#core-concepts)
- [Workflow](#workflow)
- [Architecture Alignment](#architecture-alignment)
- [Example](#example)

## When to Use

Use this skill when a widget's visual style or behavior must react to interaction state changes.

- Buttons, chips, cards, or custom atoms that need state-aware color, elevation, border, or icon changes.
- Components requiring parity across `hovered`, `focused`, `pressed`, `selected`, and `disabled` states.
- Reusable design-system components that must remain theme-driven and testable.

## Core Concepts

- **`WidgetState`**: Represents interaction states such as `pressed`, `hovered`, `focused`, `selected`, `disabled`, and `dragged`.
- **`WidgetStateProperty<T>`**: Resolves values dynamically from the active set of states.
- **`WidgetStatesController`**: External controller used to observe or force widget states deterministically (useful for testing and advanced interactions).

State resolution priority should be explicit and deterministic:

1. `disabled`
2. `pressed`
3. `hovered`
4. `focused`
5. `selected`
6. fallback/default

## Workflow

Copy and track this checklist when implementing a dynamic-state widget.

- [ ] Define the widget API with explicit inputs (`enabled`, `selected`, callbacks, semantic label).
- [ ] Keep business/domain state in BLoC/ViewModel; reserve `WidgetState` for interaction styling only.
- [ ] Create style resolvers with `WidgetStateProperty.resolveWith` (color, border, elevation, icon/text style).
- [ ] Ensure disabled behavior is consistent: null callback + disabled visual treatment.
- [ ] Validate keyboard and pointer accessibility (`focus`, `hover`, semantics).
- [ ] Add widget tests for at least default, pressed/hovered, selected, and disabled states.

## Architecture Alignment

Follow project conventions while applying dynamic styling:

- **Presentation layer only:** `WidgetState` logic belongs in widgets, not repositories or use cases.
- **Atomic design:** Keep state-aware styling at atom/molecule level and compose into organisms/screens.
- **Theming first:** Resolve from `ThemeData`/design tokens instead of hardcoding color constants.
- **Testability:** Inject `WidgetStatesController` only when the behavior requires deterministic state orchestration.

## Example

```dart
import 'package:flutter/material.dart';

class StatefulActionChip extends StatelessWidget {
  const StatefulActionChip({
    super.key,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.controller,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final WidgetStatesController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundResolver(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return theme.colorScheme.surfaceContainerHighest;
      }
      if (states.contains(WidgetState.pressed)) {
        return theme.colorScheme.primaryContainer;
      }
      if (states.contains(WidgetState.hovered)) {
        return theme.colorScheme.primaryContainer.withValues(alpha: 0.7);
      }
      if (states.contains(WidgetState.selected) || selected) {
        return theme.colorScheme.primary;
      }
      return theme.colorScheme.surface;
    }

    Color foregroundResolver(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return theme.colorScheme.onSurface.withValues(alpha: 0.38);
      }
      if (states.contains(WidgetState.selected) || selected) {
        return theme.colorScheme.onPrimary;
      }
      return theme.colorScheme.onSurface;
    }

    return ActionChip(
      statesController: controller,
      onPressed: onPressed,
      label: Text(label),
      backgroundColor: WidgetStateProperty.resolveWith(backgroundResolver),
      labelStyle: WidgetStateTextStyle.resolveWith(
        (states) => theme.textTheme.labelLarge!.copyWith(
          color: foregroundResolver(states),
          fontWeight: states.contains(WidgetState.pressed)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.focused)
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
```

## Validation Notes

- Avoid coupling `WidgetState` directly to domain state machines; map domain state to simple booleans/inputs.
- Do not rely on hover-only affordances for critical UX paths (mobile has no hover).
- Prefer a single, shared resolver per style dimension to keep state precedence consistent.

