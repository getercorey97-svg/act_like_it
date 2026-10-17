# Android SDK 36 SharedPreferences Kotlin Coroutine Fix (`pubspec.yaml`)

This plan resolves the fatal native Android initialization crash (`java.lang.NoSuchMethodError: no non-static method "Lio/flutter/plugins/sharedpreferences/SharedPreferencesApiRegistrar;.getAll(...)"`) caught by the Safe Boot Diagnostic screen when running on Android SDK 36.

## User Review & Critical Decisions

> [!IMPORTANT]
> **Strict Code Isolation Enforced**: No existing dependencies, scripts, or structural elements in `pubspec.yaml` or any Dart application files will be altered, removed, or refactored. Only the `shared_preferences` version constraint and the `dependency_overrides` block at the bottom of `pubspec.yaml` will be modified.

- **Confirmed Decision 1 (Version Constraints)**: Upgrade `shared_preferences` to `^2.5.2` in `dependencies` and pin `shared_preferences_android: ^2.4.7` in `dependency_overrides`.
- **Confirmed Decision 2 (Override Scope)**: Override only `shared_preferences_android: ^2.4.7` in `dependency_overrides` so Gradle/Kotlin resolves the updated Pigeon coroutine method signatures without disturbing other packages.

---

## 1. Overview & Core Concept

- **What It Does**: Eliminates the native Android JNI/Kotlin method signature mismatch in `SharedPreferencesPlugin` during startup (`OfflineManager.instance.initialize()` and `Supabase.initialize()`).
- **Target Audience / Persona**: Mobile players running the release APK compiled against Android SDK 36 on devices such as the Samsung Galaxy S26 Ultra.
- **Key Value**: Restores clean native plugin initialization for local scene caching and auth session persistence while preserving all existing LiveKit, Supabase, and Gemini functionality.

---

## 2. User Experience & Visual Design

- **Key User Flows**:
  1. **App Launch**: On cold boot, the Flutter engine initializes `SharedPreferencesAsync` / `SharedPreferencesPlugin` over the updated Android Pigeon channel without throwing `NoSuchMethodError`.
  2. **Living Marquee Entry**: Because native initialization succeeds without triggering the Safe Boot Diagnostic fallback screen, the user lands directly on the animated Living Marquee dashboard.
  3. **Workspace Inspection & GitHub Sync**: The AI Studio workspace viewer displays the complete, copy-pasteable `pubspec.yaml` file ready for one-tap GitHub synchronization.
- **Visual Identity & Theme**: Preserves the existing Obsidian & Gold Cinema (`#07070B` / `#F5B041`) Living Marquee aesthetic and Safe Boot Diagnostic telemetry wrapper untouched.
- **Interactive Feedback & Motion**: No visual or motion regressions; startup transitions smoothly from the splash screen into the Living Marquee dashboard.

---

## 3. Key Product Decisions & Trade-Offs

- **Decision 1: Upgrade `shared_preferences` to `^2.5.2` + `shared_preferences_android: ^2.4.7` Override**
  - *Chosen Approach*: Update `shared_preferences: ^2.5.2` under `dependencies:` and append a `dependency_overrides:` section with `shared_preferences_android: ^2.4.7`.
  - *Why*: `supabase_flutter` and older transitive dependencies can lock an older `shared_preferences_android` implementation whose Pigeon-generated Kotlin interface lacks the updated `Continuation` signature expected under Kotlin 2.x / Android SDK 36. Forcing `shared_preferences_android: ^2.4.7` guarantees compatible bytecode across all transitive callers.
  - *Alternatives Considered*: Downgrading Android compileSdk — rejected because newer camera/WebRTC plugins require compileSdk 35/36.

---

## 4. Technical Architecture & Data Strategy *(Technical Reference)*

### Architecture & Dependency Resolution Flow

```
┌───────────────────────────────────────────────────────────────────────┐
│                         Flutter App Cold Boot                         │
│           (Supabase.initialize() + OfflineManager.initialize())       │
└───────────────────────────────────┬───────────────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────────────────────────────────────────┐
│                    Dart Package: shared_preferences                   │
│                          Constraint: ^2.5.2                           │
└───────────────────────────────────┬───────────────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────────────────────────────────────────┐
│             dependency_overrides: shared_preferences_android          │
│                          Forced Version: ^2.4.7                       │
│   Aligns Pigeon Kotlin Coroutine Signatures with Android SDK 36       │
└───────────────────────────────────┬───────────────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────────────────────────────────────────┐
│        Android Native: SharedPreferencesApiRegistrar.getAll(...)      │
│       Executes cleanly without java.lang.NoSuchMethodError            │
└───────────────────────────────────────────────────────────────────────┘
```

### Data Model & State
- All existing `SharedPreferences` keys (`act_like_it_cached_scenes_v1`, `act_like_it_offline_queue_v1`, `act_like_it_match_history_v1`, and Supabase Auth tokens) remain 100% compatible with `shared_preferences: ^2.5.2`.

### Interactive Component & State Mapping
- Upon approval, `pubspec.yaml` will be updated in the workspace and surfaced in the workspace previewer, and the complete `pubspec.yaml` contents will be output in a single clean code block for verification and GitHub sync.
