---
name: flutter-detect-security-and-memory-issues
description: Detect common Flutter security, pentest, and memory leak issues. Use when auditing app hardening, insecure data flows, lifecycle leaks, and performance regressions before release.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 16 Jun 2026 07:20:00 GMT
---
# Detecting Security and Memory Issues in Flutter

## Contents
- [Audit Goals](#audit-goals)
- [Pentest-Oriented Security Checks](#pentest-oriented-security-checks)
- [Memory Leak and Retention Checks](#memory-leak-and-retention-checks)
- [Verification Tooling](#verification-tooling)
- [Workflow](#workflow)
- [Example Findings](#example-findings)

## Audit Goals

Use this skill to review a Flutter application for issues that are easy to miss during feature development but costly in production:

- Sensitive data exposure
- Insecure network and storage behavior
- Unsafe WebView or platform-channel integrations
- Lifecycle leaks from controllers, subscriptions, timers, and overlays
- Excessive memory retention, image pressure, and isolate misuse

Treat this as a release-readiness and hardening pass, not only a style review.

## Pentest-Oriented Security Checks

### 1. Secrets and Sensitive Data

Check for:

- API keys, bearer tokens, client secrets, or test credentials committed to source
- Tokens, passwords, or PII written to logs, crash reports, or analytics events
- Sensitive values passed through query parameters instead of headers or secure bodies
- Debug-only backdoors, hardcoded admin flags, or hidden environment switches

### 2. Local Storage and Session Handling

Check for:

- Tokens or refresh credentials stored in plaintext files or shared preferences without an approved secure storage boundary
- Missing logout cleanup that leaves tokens, cached user data, or permission-derived data on device
- Overly broad persistence of profile, payment, or health data

### 3. Network and Transport Hardening

Check for:

- Cleartext HTTP usage in production paths
- Disabled certificate validation, permissive bad-certificate callbacks, or debug networking code left enabled
- Missing timeout, retry, or error handling paths that can expose unstable or replay-prone request flows
- Untrusted redirects, unvalidated download URLs, or unsafe file upload handling

### 4. Input and Surface Validation

Check for:

- WebView JavaScript channels exposing privileged native actions without origin validation
- Dynamic route, deep link, or intent handling that trusts unvalidated external input
- File pickers, share targets, or imported payloads accepted without content or size validation
- User-controlled HTML, markdown, or rich text rendered without sanitization

### 5. Permissions and Platform Boundaries

Check for:

- Unnecessary runtime permissions or requests made before user intent is clear
- Platform channel methods that expose native capabilities without argument validation
- Camera, microphone, location, and storage flows that continue after permission revocation

## Memory Leak and Retention Checks

### 1. Disposable Objects

Verify that these are always disposed, cancelled, or closed:

- `AnimationController`
- `ScrollController`
- `TabController`
- `PageController`
- `TextEditingController`
- `FocusNode`
- `StreamSubscription`
- `Timer`
- `ChangeNotifier`
- `Cubit` / `Bloc` instances created outside managed providers

### 2. Widget Lifecycle Risks

Check for:

- Long-lived references to `BuildContext`, `State`, or widget instances after disposal
- Async callbacks calling `setState` after widget unmount
- Listeners added in `initState` and never removed in `dispose`
- Overlay entries, dialogs, and route observers that outlive the screen that created them

### 3. State Management Retention

Check for:

- Feature caches that grow without eviction limits
- BLoCs, repositories, or service singletons retaining screen-scoped data
- Streams that never complete or are re-subscribed on every rebuild
- Global keys or static collections holding UI objects indefinitely

### 4. Media and Large Object Pressure

Check for:

- Full-resolution images loaded when thumbnails are sufficient
- Repeated decoding of large assets without caching strategy
- Large JSON parsing on the UI isolate causing jank and temporary memory spikes
- File buffers, isolates, or ports kept alive after one-shot work completes

## Verification Tooling

Use the existing ecosystem to confirm findings:

- `flutter analyze` for obvious lifecycle and API misuse
- `flutter test` for regression coverage where tests exist
- Flutter DevTools Memory view for heap growth, retaining paths, and snapshot comparison
- Flutter DevTools Performance view to correlate jank with allocation spikes
- `dart pub outdated` and dependency review for stale packages with known risk
- Secret scanning and dependency advisory tooling before commit or release

When a suspected leak is not obvious from code review, reproduce the screen flow, capture memory snapshots before and after repeated navigation, and compare retained objects.

## Workflow

### Task Progress
- [ ] **Step 1: Define Audit Scope.** Identify sensitive features such as auth, payments, file uploads, WebViews, deep links, and long-lived screens.
- [ ] **Step 2: Review Static Risks.** Search for secrets, insecure transport settings, unsafe storage, and missing dispose/cancel paths.
- [ ] **Step 3: Inspect Lifecycle Ownership.** Trace who creates and who disposes controllers, subscriptions, timers, overlays, and BLoCs.
- [ ] **Step 4: Exercise Runtime Flows.** Reproduce high-risk navigation and background/foreground scenarios while watching logs and memory growth.
- [ ] **Step 5: Validate with Tooling.** Run analyzer, tests, and DevTools memory inspection to confirm or reject suspected issues.
- [ ] **Step 6: Report Findings by Severity.** Separate exploitable security issues, confirmed leaks, and follow-up monitoring recommendations.

## Example Findings

### Security Finding
- A Dio client accepts all certificates through a permissive `badCertificateCallback`, allowing interception in production builds.

### Memory Finding
- A screen-owned `StreamSubscription` is created in `initState` but never cancelled, causing duplicate listeners and retained state after repeated navigation.

### Performance-Related Memory Finding
- A large API response is decoded and mapped on the main isolate for every refresh, producing frame drops and short-lived memory spikes on lower-end devices.
