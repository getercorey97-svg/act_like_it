# Paparazzi Red Carpet Dashboard & Director's Call Sheet Overhaul

This plan transforms the main dashboard experience into a first-person Paparazzi Red Carpet journey with parallax scrolling, randomized camera flash bursts, `GoogleFonts.limelight` headlines, 6 vertical "Door" cards, the zero-clutter "Call Sheet" pre-game configuration modal (`lib/ui/game_settings_modal.dart`), and a dedicated Scene Vault screen (`lib/ui/scene_vault_screen.dart`), while keeping all Supabase matchmaking, Realtime channel synchronization, and LiveKit WebRTC SFU logic 100% untouched.

## Visual Direction & Domain Exemplars

- **Exemplars**: Netflix Studio Premiere Showcase & MasterClass Mobile Stage—tactile obsidian cards (`#07090E`), dramatic crimson red-carpet perspective lighting, and crisp studio soundboard controls.
- **Color & Atmospheric Polarity**: Intentional Dark Mode (`#07090E` deep obsidian canvas, `#13080D` velvet carpet shadow, `#E11D48` carpet crimson, `#F59E0B` limelight gold, `#06B6D4` soundstage cyan, `#A855F7` after-hours violet).
- **Typography**: `GoogleFonts.limelight` exclusively for the `"ACT LIKE IT"` marquee title and the 6 Door headers; crisp monospace for room codes, slate numbers, and studio soundboard readouts.
- **Layout & Spatial Architecture**:
  - **Interactive Paparazzi Stack**: Base layer renders a custom first-person perspective Red Carpet with velvet stanchion ropes that shifts vertically via a `ScrollController` parallax listener; overlay layer triggers randomized high-key white/amber camera flash bursts driven by an `AnimationController`.
  - **Zero-Clutter CustomScrollView**: Removes the top Tri-Modal metric rings from the main dashboard and replaces them with a spacious vertical `CustomScrollView` of 6 heavily shadowed cinematic "Doors".

## Key Changes

### 1. Dependency Injection (`pubspec.yaml`)
- Add `google_fonts: ^6.2.1` under `dependencies:` in `pubspec.yaml` while preserving all existing packages and `dependency_overrides: shared_preferences_android: ^2.4.28`.

### 2. The "Call Sheet" Pre-Game Settings Modal (`lib/ui/game_settings_modal.dart` — New File)
- Create a stateful `GameSettingsModal` designed for `showModalBottomSheet` with a `#07090E` obsidian surface and `SingleChildScrollView(padding: EdgeInsets.all(24.0))` with generous vertical spacing (`24px–28px` between sections).
- **The Studio Toggles**: Three oversized tactile studio soundboard switches for **AI Telemetrics (45%)**, **Peer Judging (35%)**, and **Social Judging (20%)**.
- **Improv Roulette**: A glowing neon **Wildcard** toggle switch enabling random mid-scene improvisation modifiers.
- **Action Button**: A full-width, neon-bordered **"ROLL CAMERA"** CTA at the bottom that closes the modal, returns the selected `GameSettingsConfig`, and advances directly into the lobby or soundstage.

### 3. The Scene Vault Screen (`lib/ui/scene_vault_screen.dart` — New File)
- Create `SceneVaultScreen` featuring a dedicated swipeable carousel of oversized perforated movie tickets covering **Eras: 1970–1999**, **Eras: 2000–2026**, **Cult Classics**, and **Award Vaults**.
- Tapping any movie ticket invokes `showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const GameSettingsModal())` before launching the selected era into `LobbyMatchmakingScreen` / `LiveKitSoundstageScreen`.

### 4. First-Person Paparazzi Dashboard (`lib/dashboard_marquee.dart` & `lib/lobby.dart` UI Overhaul Only)
- **Strict Backend Isolation**: Keep `SceneCategory`, `ScenePrompt`, `LobbyRealtimeManager`, Supabase queries, Realtime channels, and WebRTC SFU calls completely untouched.
- **Paparazzi Red Carpet & Parallax `CustomScrollView`**:
  - Update the main dashboard (`LivingMarqueeDashboardScreen` in `lib/dashboard_marquee.dart`, plus the entry form header in `lib/lobby.dart`) to render the First-Person Red Carpet parallax background + randomized Paparazzi Flash overlay.
  - Strip the top Tri-Modal Judging metric rings from the main screen and render the 6 vertical cinematic Doors inside a `CustomScrollView`:
    - **The Premiere Door**: *Create Lobby / Quick Play* (Glowing Director's Clapperboard) — triggers `GameSettingsModal` then routes to `LobbyMatchmakingScreen`.
    - **Door 1**: *Join 6-Digit Room* ("On Air" Stage Light) — triggers `GameSettingsModal` (or routes directly into 6-digit Join mode).
    - **Door 2**: *18+ After-Hours* (Neon Velvet Rope / VIP Pass) — routes to `LateNightAfterHoursScreen`.
    - **Door 3**: *Career Trophy Room* (Golden Statuette) — routes to `MatchHistoryScreen`.
    - **Door 4**: *How to Play / Instructions* (Director's Megaphone) — routes to `InteractiveInstructionsScreen`.
    - **Door 5**: *The Scene Vault* (Vintage Box Office Window) — routes to `SceneVaultScreen`.

## Verification Plan
- Run `compile_applet` to verify zero Dart or TypeScript build issues across all new and updated files.
- Verify all 6 Doors, the `GameSettingsModal` bottom sheet trigger, `SceneVaultScreen` ticket swiper, and `GoogleFonts.limelight` typography render cleanly without touching Supabase or WebRTC backend classes.
