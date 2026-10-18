# Missing `MatchHistoryScreen` Placeholder Fix

This plan resolves the GitHub Actions `assembleRelease` compilation failure (`Error when reading 'lib/match_history_screen.dart': No such file or directory`) by generating a clean, standalone stateless `MatchHistoryScreen` widget while leaving all existing codebase files untouched.

## User Review & Critical Decisions

> [!IMPORTANT]
> **Strict Code Isolation**: Per your instructions, zero existing files, UI themes, or dependencies will be altered, rewritten, or updated. Only the missing `MatchHistoryScreen` placeholder module will be created so the compiler can resolve the import and link the release APK cleanly.

- **Confirmed Decision 1 — Widget Structure**: Implement `MatchHistoryScreen` as a minimal `StatelessWidget` with a `const MatchHistoryScreen({super.key})` constructor, a `Scaffold`, an `AppBar` titled `"Match History"`, and a centered placeholder body.
- **Confirmed Decision 2 — Visual Styling**: Apply the app's dark backstage palette (`#07090E` scaffold background and `#0B0E17` dark `AppBar`) so navigating to the screen is visually seamless with the Living Marquee dashboard.

---

## 1. Overview & Core Concept

- **What It Does**: Provides the missing `MatchHistoryScreen` widget imported by the Living Marquee dashboard when pausing the Game Show background music before navigation.
- **Target Audience / Persona**: Mobile players on Android (Samsung Galaxy S26 Ultra) and the automated GitHub Actions cloud build pipeline (`flutter build apk --release`).
- **Key Value**: Eliminates the broken import error during `assembleRelease` while guaranteeing zero regression risk to the existing audio engine, dashboard animations, or Android SDK 36 configuration.

---

## 2. User Experience & Visual Design

- **Key User Flows**:
  1. The user taps the Career Trophy Room / Match History button on the Living Marquee dashboard.
  2. The dashboard pauses the looping Game Show background music (`_pauseMusicBeforeNavigation()`) and pushes `const MatchHistoryScreen()`.
  3. `MatchHistoryScreen` renders a dark backstage `Scaffold` with a `"Match History"` `AppBar` and a clean centered placeholder view, allowing the user to return to the dashboard via the standard back button.
- **Visual Identity & Theme**:
  - *Aesthetic Direction*: Backstage Dark (`#07090E` background, `#0B0E17` surface, `#10B981` emerald trophy accent, crisp white typography).
  - *Typography & Hierarchy*: Bold `AppBar` header (`"Match History"`) paired with a clean centered subtitle indicating the Career Trophy Room & Match History placeholder view.
  - *Component Styling & Layout*: Pure Flutter Material `StatelessWidget` with zero external package dependencies beyond `package:flutter/material.dart`.
- **Interactive Feedback & Motion**: Standard Material back navigation returning cleanly to the Living Marquee dashboard.

---

## 3. Key Product Decisions & Trade-Offs

- **Decision 1: Standalone `StatelessWidget` with `const` Constructor**
  - *Chosen Approach*: Define `class MatchHistoryScreen extends StatelessWidget` with `const MatchHistoryScreen({super.key});` importing only `package:flutter/material.dart`.
  - *Why*: Matches the exact call site (`builder: (_) => const MatchHistoryScreen()`) in the dashboard, requires zero additional imports that could introduce circular dependencies, and compiles deterministically in `flutter build apk --release`.
  - *Alternatives Considered*: Importing database or offline managers into the placeholder was passed over to keep the module 100% self-contained and isolated.

---

## 4. Technical Architecture & Data Strategy *(Technical Reference)*

- **Architecture & Component Diagram**:
```
┌──────────────────────────────────────────────────────────────┐
│                LivingMarqueeDashboardScreen                  │
│  • Pauses AudioPlayer (_pauseMusicBeforeNavigation)          │
│  • Pushes MaterialPageRoute(builder: (_) => const ...)       │
└──────────────────────────────┬───────────────────────────────┘
                               │ Resolves import & const constructor
                               ▼
┌──────────────────────────────────────────────────────────────┐
│               MatchHistoryScreen (StatelessWidget)           │
│  • Scaffold (backgroundColor: #07090E)                       │
│  • AppBar   (title: Text('Match History'), bg: #0B0E17)      │
│  • Body     (Centered backstage placeholder card & message)  │
└──────────────────────────────────────────────────────────────┘
```

- **Data Model & State**: Stateless presentation widget (`const MatchHistoryScreen({super.key})`) with no mutable state or asynchronous side effects.
- **Interactive Component & State Mapping**: The `AppBar` automatically provides a back navigation control (`Navigator.pop`) when pushed onto the navigation stack from the dashboard.
