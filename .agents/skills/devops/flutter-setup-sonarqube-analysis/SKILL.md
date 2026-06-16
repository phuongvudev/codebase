---
name: flutter-setup-sonarqube-analysis
description: Implement automated static code analysis and code coverage tracking using SonarQube/SonarCloud.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Mon, 16 Jun 2024 12:00:00 GMT
---
# SonarQube Analysis for Flutter

## Contents
- [Prerequisites](#prerequisites)
- [Sonar Project Properties](#sonar-project-properties)
- [Coverage Pipeline](#coverage-pipeline)
- [Filtering Generated Code](#filtering-generated-code)
- [CI/CD Integration (GitHub Actions)](#cicd-integration-github-actions)
- [Workflow](#workflow)

## Prerequisites

- **SonarQube Server / SonarCloud Account.**
- **Sonar-Scanner CLI:** Installed locally or via Docker/CI Action.
- **Java 17+:** Required by the sonar-scanner.

## Sonar Project Properties

Create `sonar-project.properties` in the project root.

```properties
sonar.projectKey=my_flutter_app
sonar.projectName=My Flutter App
sonar.sources=lib
sonar.tests=test
sonar.sourceEncoding=UTF-8

# Coverage Report Path
sonar.dart.lcov.reportPaths=coverage/lcov.info

# Exclusions
sonar.exclusions=**/*.g.dart,**/*.freezed.dart,lib/generated_plugin_registrant.dart
sonar.coverage.exclusions=test/**,**/*.g.dart,**/*.freezed.dart,lib/firebase_options.dart
```

## Coverage Pipeline

Standard steps to prepare data for SonarQube.

```bash
# 1. Run tests with coverage
flutter test --coverage

# 2. Filter out generated files (Essential for accurate metrics)
# Install: dart pub global activate remove_from_coverage
remove_from_coverage -f coverage/lcov.info -r '\.g\.dart$'
```

## Filtering Generated Code

SonarQube counts lines in generated files (like those from `json_serializable` or `freezed`) which inflates the "to be covered" count. Always use `sonar.coverage.exclusions` and physical LCOV filtering.

## CI/CD Integration (GitHub Actions)

```yaml
jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Shallow clones should be disabled for a better relevancy of analysis
      
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage
      
      - name: Filter LCOV
        run: |
          dart pub global activate remove_from_coverage
          export PATH="$PATH":"$HOME/.pub-cache/bin"
          remove_from_coverage -f coverage/lcov.info -r '\.g\.dart$'
      
      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

## Workflow

- [ ] **Step 1: Create Configuration.** Add `sonar-project.properties` to the root.
- [ ] **Step 2: Setup Sonar Project.** Create the project in SonarQube/SonarCloud and get the `SONAR_TOKEN`.
- [ ] **Step 3: Verify Coverage Generation.** Run `flutter test --coverage` locally and check `coverage/lcov.info`.
- [ ] **Step 4: Test LCOV Filtering.** Use `remove_from_coverage` to ensure `.g.dart` files are removed from the report.
- [ ] **Step 5: Configure CI.** Add the SonarQube scan step to your pull request pipeline.
- [ ] **Step 6: Set Quality Gate.** Configure Sonar to fail the build if coverage falls below a target (e.g., 80%).
