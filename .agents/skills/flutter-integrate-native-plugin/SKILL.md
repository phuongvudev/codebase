---
name: flutter-integrate-native-plugin
description: Integrate Flutter with native Android/iOS code using MethodChannel for simple use cases and build a reusable plugin for advanced cross-project native capabilities.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 16 Jun 2026 07:30:00 GMT
---
# Flutter ↔ Native Integration (Simple + Advanced)

## Contents
- [When to Use](#when-to-use)
- [Simple Case Study: MethodChannel Inside App](#simple-case-study-methodchannel-inside-app)
- [Advanced Case Study: Create and Integrate a New Plugin](#advanced-case-study-create-and-integrate-a-new-plugin)
- [Validation Checklist](#validation-checklist)
- [Workflow](#workflow)

## When to Use

Use this skill when a Flutter feature requires platform-specific APIs that are unavailable or limited in pure Dart.

Choose approach by scope:
- **Simple case (in-app channel):** one feature, one app, low reuse needs.
- **Advanced case (plugin):** reusable capability, multiple features/apps, stronger versioning and testing needs.

---

## Simple Case Study: MethodChannel Inside App

### Scenario
Expose native battery level to Flutter UI.

### Architecture Guidance
- Keep `MethodChannel` access in the **Data** layer.
- Expose capability through a **Domain contract** (`Repository` or service interface).
- Trigger from **Presentation** via BLoC event.
- Return typed failures (platform exception / unavailable API / permission denied).

### Implementation Steps
1. Define domain contract: `DeviceInfoRepository.getBatteryLevel()`.
2. Implement repository in data layer with `MethodChannel('codebase/device_info')`.
3. Android implementation:
   - Handle `getBatteryLevel` in `MainActivity` (or Android host).
   - Use `BatteryManager` and return integer percentage.
4. iOS implementation:
   - Handle `getBatteryLevel` in `AppDelegate`/`Runner` host.
   - Use `UIDevice.current.batteryLevel` with monitoring enabled.
5. Register implementation in GetIt.
6. Add BLoC event/state to load battery level and display in UI.

### Error Boundary
Handle and map these cases explicitly:
- Method not implemented on one platform.
- API returns unknown/unavailable values.
- Runtime permission constraints (if platform API requires it).

---

## Advanced Case Study: Create and Integrate a New Plugin

### Scenario
Build a reusable plugin for biometric availability checks and native secure-key operations.

### Plugin Strategy
- Create plugin package (federated-ready naming if expected to scale).
- Keep platform channel API stable and versioned.
- Design DTO/result contracts that are platform-agnostic.

### Implementation Steps
1. Create plugin:
   ```bash
   flutter create --template=plugin --platforms=android,ios flutter_native_secure_bridge
   ```
2. Define public Dart API in plugin:
   - `isBiometricAvailable()`
   - `createOrGetKey(alias)`
   - `signPayload(alias, payload)`
3. Implement Android native side:
   - Kotlin channel handler in plugin class.
   - BiometricManager + Android Keystore APIs.
4. Implement iOS native side:
   - Swift channel handler in plugin class.
   - LocalAuthentication + Keychain/Secure Enclave APIs.
5. Add robust error codes/messages shared by both platforms.
6. Add unit tests in plugin Dart layer and platform interface checks.
7. Integrate plugin into app:
   - Add dependency using path or git reference.
   - Create repository adapter in app data layer.
   - Register adapter in GetIt and consume via BLoC.
8. Add integration test flow in app for plugin-backed feature.

### Production Notes
- Keep channel method names immutable after release.
- Use semantic versioning for plugin API changes.
- Add platform capability guards before invoking secure APIs.
- Ensure fallback UI/flows when capability is unavailable.

---

## Validation Checklist

- Flutter-side API compiles and is type-safe.
- Android and iOS handlers return consistent payload shapes.
- Unsupported platform behavior is deterministic.
- Exceptions are mapped to domain-safe failure models.
- BLoC/UI presents loading, success, and failure states.
- Integration test covers at least one happy path and one error path.

## Workflow

- [ ] **Task Progress: Discovery**
  - [ ] Identify required native capability and platform scope.
  - [ ] Decide between in-app channel and plugin.
- [ ] **Task Progress: Contracting**
  - [ ] Define domain interface and result/failure models.
  - [ ] Define channel method names and payload contract.
- [ ] **Task Progress: Native Integration**
  - [ ] Implement Android and iOS handlers.
  - [ ] Add permission/capability checks.
- [ ] **Task Progress: App Wiring**
  - [ ] Implement data repository adapter.
  - [ ] Register dependencies in GetIt.
  - [ ] Connect BLoC events and UI states.
- [ ] **Task Progress: Verification**
  - [ ] Run analyzer/tests.
  - [ ] Validate both success and failure flows.
