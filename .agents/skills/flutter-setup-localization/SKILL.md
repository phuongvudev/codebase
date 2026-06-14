---
name: flutter-setup-localization
description: Use `intl_utils` to generate a type-safe `S` class for internationalization. Use when you prefer an IDE-driven workflow or integrated Localizely support.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 16:00:00 GMT
---
# Internationalizing Flutter Applications with intl_utils

## Contents
- [Core Concepts](#core-concepts)
- [Setup Workflow](#setup-workflow)
- [Implementation Workflow](#implementation-workflow)
- [Advanced Formatting](#advanced-formatting)
- [Examples](#examples)

## Core Concepts
Flutter handles internationalization (i18n) and localization (l10n) via the `flutter_localizations` and `intl` packages. Using `intl_utils` (often paired with the "Flutter Intl" IDE plugin) provides a streamlined workflow by generating a type-safe `S` class from App Resource Bundle (`.arb`) files.

Unlike the standard `l10n.yaml` approach, `intl_utils` generates code directly into your `lib/generated/` folder, allowing for easier inspection and IDE autocomplete without a synthetic package.

## Setup Workflow

Copy and track this checklist when initializing internationalization:

- [ ] **Task Progress**
  - [ ] 1. Add dependencies to `pubspec.yaml`.
  - [ ] 2. Configure `flutter_intl` in `pubspec.yaml`.
  - [ ] 3. Create the ARB directory and template file.
  - [ ] 4. Configure `MaterialApp` or `CupertinoApp`.

### 1. Add Dependencies
Execute the following commands in the terminal:
```bash
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl:any
flutter pub add --dev intl_utils:any
```

Verify your `pubspec.yaml` includes the following:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

dev_dependencies:
  intl_utils: any
```

### 2. Configure intl_utils
Add the `flutter_intl` configuration block to the end of your `pubspec.yaml`:
```yaml
flutter_intl:
  enabled: true
  arb_dir: lib/l10n
  template_arb_file: app_en.arb
  output_dir: lib/generated
```

### 3. Configure the App Entry Point
Import the generated `S` class and the `flutter_localizations` library. Inject the delegates into your `MaterialApp` or `CupertinoApp`.

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart'; // Path to the generated S class

// ... inside build method
return MaterialApp(
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: const MyHomePage(),
);
```

## Implementation Workflow

### 1. Define ARB Files
*   **Location:** `lib/l10n/app_en.arb` (Template)
*   **Action:** Add keys and values in JSON format.

```json
{
  "helloWorld": "Hello World!",
  "@helloWorld": {
    "description": "The conventional newborn programmer greeting"
  }
}
```

### 2. Generate Localization Classes
If you are not using the IDE plugin with "auto-generate on save", run the following command manually:
```bash
dart run intl_utils:generate
```
This updates the files in `lib/generated/`.

### 3. Consume Localized Strings
Access strings using `S.of(context)`.

```dart
Text(S.of(context).helloWorld)
```

## Advanced Formatting (ICU Syntax)

### Placeholders
```json
"hello": "Hello {userName}",
"@hello": {
  "placeholders": {
    "userName": {}
  }
}
```
**Usage:** `S.of(context).hello("Bob")`

### Plurals
```json
"nWombats": "{count, plural, =0{no wombats} =1{1 wombat} other{{count} wombats}}",
"@nWombats": {
  "placeholders": {
    "count": {}
  }
}
```
**Usage:** `S.of(context).nWombats(5)`

### Selects (e.g., Gender)
```json
"pronoun": "{gender, select, male{he} female{she} other{they}}",
"@pronoun": {
  "placeholders": {
    "gender": {}
  }
}
```
**Usage:** `S.of(context).pronoun("female")`

## Examples

### Complete Widget Implementation
```dart
import 'package:flutter/material.dart';
import 'generated/l10n.dart';

class GreetingWidget extends StatelessWidget {
  final String userName;
  final int notificationCount;

  const GreetingWidget({
    super.key, 
    required this.userName, 
    required this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Column(
      children: [
        Text(l10n.hello(userName)),
        Text(l10n.nWombats(notificationCount)),
      ],
    );
  }
}
```
