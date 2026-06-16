---
name: flutter-setup-fastlane-ci-cd
description: Implement professional CI/CD pipelines for Flutter using Fastlane. Covers multi-platform deployment, API-based authentication, and automated code signing.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Mon, 16 Jun 2024 12:00:00 GMT
---
# Flutter CI/CD with Fastlane

## Contents
- [Prerequisites](#prerequisites)
- [Initialization Strategy](#initialization-strategy)
- [Authentication (Modern API-First)](#authentication-modern-api-first)
- [Code Signing (iOS Match & Android Keystore)](#code-signing-ios-match--android-keystore)
- [Standard Lanes (2025 Mobile Standard)](#standard-lanes-2025-mobile-standard)
- [Flutter-Specific Optimizations](#flutter-specific-optimizations)
- [CI/CD Integration (GitHub Actions)](#cicd-integration-github-actions)

## Prerequisites

- **Ruby:** 3.0+
- **Bundler:** `gem install bundler`
- **Fastlane:** Recommended via Gemfile.

## Initialization Strategy

Always use a `Gemfile` in both `android/` and `ios/` directories to ensure version parity between local and CI environments.

```bash
# In [project]/android/ and [project]/ios/
fastlane init
```

### Gemfile (Recommended)
```ruby
source "https://rubygems.org"
gem "fastlane"
gem "fastlane-plugin-flutter_version" # Single source of truth from pubspec.yaml
```

## Authentication (Modern API-First)

Avoid manual sessions. Use Service Accounts and API Keys.

### iOS: App Store Connect API
Use `app_store_connect_api_key` in your `Fastfile`.
```ruby
lane :release do
  api_key = app_store_connect_api_key(
    key_id: ENV["ASC_KEY_ID"],
    issuer_id: ENV["ASC_ISSUER_ID"],
    key_content: ENV["ASC_KEY_CONTENT"], # Base64 encoded .p8
    is_key_content_base64: true
  )
  build_app(api_key: api_key)
  upload_to_app_store(api_key: api_key)
end
```

### Android: Google Play Service Account
Store the JSON key in a CI secret and point to it via environment variable `SUPPLY_JSON_KEY_DATA`.

## Code Signing (iOS Match & Android Keystore)

### iOS (Match)
Use `match` with a private Git repository for certificates and profiles.
```ruby
lane :beta do
  match(type: "appstore", readonly: is_ci) # Prevent CI from creating new certs
  build_app(scheme: "Release")
end
```

### Android (Keystore)
Inject keystore values via environment variables in `android/app/build.gradle`.
```gradle
signingConfigs {
    release {
        storeFile file(System.getenv("ANDROID_KEYSTORE_PATH"))
        storePassword System.getenv("ANDROID_KEYSTORE_PASSWORD")
        keyAlias System.getenv("ANDROID_KEY_ALIAS")
        keyPassword System.getenv("ANDROID_KEY_PASSWORD")
    }
}
```

## Standard Lanes (2025 Mobile Standard)

| Lane | Purpose | Actions |
| :--- | :--- | :--- |
| `lint_test` | Pre-flight check | `flutter analyze`, `flutter test` |
| `internal` | QA/QA distribution | Android Internal Track, iOS Firebase/TestFlight |
| `beta` | Public Beta | Play Store Beta, TestFlight |
| `release` | Production | Play Store Production, App Store |

## Flutter-Specific Optimizations

### 1. Versioning from Pubspec
Use `flutter_version` plugin to sync versions automatically.
```ruby
lane :bump_version do
  v = flutter_version()
  puts "Building version: #{v[:version_name]} (#{v[:version_code]})"
end
```

### 2. Clean Builds
Always start lanes with a clean state.
```ruby
before_all do
  sh "flutter clean"
  sh "flutter pub get"
end
```

## CI/CD Integration (GitHub Actions)

Example workflow snippet for automated builds:

```yaml
jobs:
  deploy_ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - name: Install Fastlane
        run: cd ios && bundle install
      - name: Deploy to TestFlight
        run: cd ios && bundle exec fastlane beta
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          ASC_KEY_CONTENT: ${{ secrets.ASC_KEY_CONTENT }}
          # ... other secrets
```

---

## Workflow

- [ ] **Step 1: Environment Setup.** Create `Gemfile` in `android/` and `ios/`.
- [ ] **Step 2: Initialize Fastlane.** Run `fastlane init` in both platform folders.
- [ ] **Step 3: Configure Authentication.** Set up ASC API Key and Play Service Account.
- [ ] **Step 4: Setup Code Signing.** Run `match init` for iOS; configure `build.gradle` for Android.
- [ ] **Step 5: Define Lanes.** Implement `lint_test`, `beta`, and `release` in `Fastfile`.
- [ ] **Step 6: CI Integration.** Create GitHub Actions or GitLab CI yaml using the lanes.
