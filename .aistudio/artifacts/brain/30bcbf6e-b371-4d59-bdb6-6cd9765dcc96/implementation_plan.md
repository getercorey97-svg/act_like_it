# Hyper-Fluid 3D Red Carpet Engine & Bespoke Studio Doors Overhaul

Transforms the **ACT LIKE IT** home dashboard and lobby entry experience into a 60/120fps first-person 3D Hollywood premiere engine featuring volumetric searchlights, a touch-reactive 3D holographic marquee, a scroll-velocity-reactive 3D red carpet with swinging stanchion ropes and 4-point star-burst paparazzi lens flares, 12-degree finger-tracking 3D tilt physics, and six custom-crafted architectural studio doors—while preserving 100% of existing backend services, navigation routes, and compiler configurations.

## User Review & Critical Decisions

> [!IMPORTANT]
> Both Phase 1 preferences have been locked in and incorporated into this architecture:

- **Confirmed Scope**: The Interactive 3D Holographic Marquee, First-Person 3D Red Carpet & Paparazzi Engine, `Interactive3DDoorCard` physics wrapper, and all 6 Bespoke Architectural Doors will be rendered on both the primary home dashboard and the lobby entry screen.
- **Confirmed Physics & Haptics Profile**: Responsive **12-degree** 3D touch-tilt (`rotateX` / `rotateY`) with live finger-tracking specular glare, subtle `HapticFeedback.selectionClick()` ticks when scrolling past each brass stanchion post, `HapticFeedback.mediumImpact()` on mechanical door activation, and `HapticFeedback.heavyImpact()` + 10-flash paparazzi burst on marquee taps.
- **Strict Non-Destructive Lockdown**: Zero modifications to CI/CD workflows, package dependencies, `SafeBootDiagnostics`, `OfflineManager`, `LobbyRealtimeManager`, WebRTC SFU routing, or Gemini judging logic.

---

## 1. Overview & Core Concept

- **What It Does**: Replaces static, flat card layouts and literal prompt labels with an interactive 3D Hollywood premiere environment where players walk down a perspective velvet carpet flanked by photographer silhouettes, swinging velvet ropes, golden bokeh particles, and six distinct physical studio entrances.
- **Target Audience / Persona**: Mobile performers and party players on the Samsung Galaxy S26 Ultra seeking a tactile, high-frame-rate game-engine feel with immediate visual and haptic feedback.
- **Key Value**: Eliminates all meta-text and developer jargon from the UI while elevating every scroll, drag, and tap into a responsive 3D mechanical interaction.

---

## 2. User Experience & Visual Design

- **Key User Flows**:
  1. **Premiere Arrival & Paparazzi Frenzy**: Launching the app reveals twin volumetric searchlights sweeping behind the 3D chrome-and-gold **ACT LIKE IT** marquee. Tapping the marquee triggers a heavy haptic thud, a 3D elastic bounce, and an immediate 10-flash camera burst across the screen.
  2. **Walking the Red Carpet**: Scrolling down advances the player along the 3D royal crimson runner as gold brass stanchions and velvet ropes scale up and rush past peripheral vision, triggering subtle haptic ticks at each post and spiking camera flash frequency with scroll velocity.
  3. **3D Touch-Tilt & Bespoke Door Activation**: Touching or dragging across any of the 6 doors tilts the door up to 12 degrees toward the finger with a live specular spotlight sweep across its frosted glassmorphic surface. Releasing or tapping triggers the door's bespoke mechanical animation (e.g., snapping the 3D clapperboard shut) before opening the existing `GameSettingsModal` or destination screen.
- **Visual Identity & Theme**:
  - *Aesthetic Direction*: AAA Hollywood Premiere Soundstage & Tactile Broadcast Console.
  - *Color Palette & Mood*: Deep Obsidian Theatre Canvas (`#05070B`), Royal Crimson Velvet (`#9F1239` to `#E11D48`), Molten 24K Gold (`#F59E0B` to `#FDE68A`), Studio Airlock Cyan (`#06B6D4`), Speakeasy Neon Magenta (`#EC4899`), and Academy Emerald (`#10B981`).
  - *Typography & Hierarchy*:
    - **Centerpiece Marquee & Scene Vault Door**: `GoogleFonts.limelight` with animated chrome/gold shader sweep and warm filament bulb chaser border.
    - **Premiere Clapperboard Door**: `GoogleFonts.bebasNeue` blockbuster display headlines.
    - **Soundstage Airlock Door**: `GoogleFonts.chakraPetch` precision studio typography.
    - **VIP Velvet Speakeasy Door**: `GoogleFonts.satisfy` flickering neon script paired with `GoogleFonts.montserrat`.
    - **Academy Vault Door**: `GoogleFonts.cinzel` engraved prestige serif.
    - **Camera Viewfinder Door**: `GoogleFonts.courierPrime` screenplay & telemetry timecode typography.
  - *Component Styling & Layout*: Minimum $48 \times 48\text{px}$ touch hitboxes, `<15%` sticky footer footprint for the floating glassmorphic Live Wire broadcast chyron, and zero static pill clutter or developer jargon.
- **Interactive Feedback & Motion**:
  - Compositor-friendly `Transform` (`Matrix4.identity()..setEntry(3, 2, 0.0012)`) for cylindrical scroll curvature and 12-degree finger-tracking tilt.
  - Custom-painted 4-point star-burst flashes, lens flare cores, and radial screen bloom (`MaskFilter.blur`).

---

## 3. Key Product Decisions & Trade-Offs

- **Decision 1: Unified 3D Engine Shared Between Home Dashboard & Lobby Entry**
  - *Chosen Approach*: Expose the reusable 3D background engine (`PaparazziRedCarpetPainter`, `PaparazziFlashOverlayPainter`), `Interactive3DHolographicMarquee`, `Interactive3DDoorCard`, and the 6 bespoke door builders so both the main dashboard and the lobby entry view share the identical 60/120fps visual architecture.
  - *Why*: Ensures visual continuity whether the user is on the root launch screen or returning to the lobby entry view, while keeping all `LobbyRealtimeManager` state and callbacks intact.
- **Decision 2: Pure CustomPainter & Matrix4 Shader/Physics Pipeline**
  - *Chosen Approach*: Implement all 3D perspective projection, bokeh particles, 12-bar audio equalizers, neon plasma flicker math, rotating sunburst halos, and ticket-notch clippers using built-in `dart:math` and `dart:ui` without adding external pub packages.
  - *Why*: Guarantees 100% compatibility with the locked Android SDK 36 CI/CD pipeline and zero native plugin conflicts on the S26 Ultra.

---

## 4. Technical Architecture & Data Strategy *(Technical Reference)*

### Architecture & Component Diagram

```
┌────────────────────────────────────────────────────────────────────────────┐
│                  60/120FPS 3D PREMIERE ENGINE (Stack)                      │
├────────────────────────────────────────────────────────────────────────────┤
│  Layer 1: 3D Red Carpet, Brass Stanchions & 40+ Bokeh Particles Painter    │
│           (ScrollController offset + velocity -> Stanchion Haptic Ticks)   │
│                                     │                                      │
│  Layer 2: Paparazzi Crowd Silhouettes & 4-Point Star-Burst Flash Painter   │
│           (Scroll velocity multiplier + Marquee Tap 10-Flash Frenzy)       │
│                                     │                                      │
│  Layer 3: CustomScrollView + Cylindrical Reel Perspective Transform        │
│     ├── Interactive3DHolographicMarquee ("ACT LIKE IT" + Dual Searchlights)│
│     └── Interactive3DDoorCard (12° Pan/Touch Tilt + Specular Glare)        │
│           ├── 1. Premiere Clapperboard Door ──► GameSettingsModal (Host)   │
│           ├── 2. Soundstage Airlock Door    ──► GameSettingsModal (Join)   │
│           ├── 3. VIP Velvet Speakeasy Door  ──► LateNightAfterHoursScreen  │
│           ├── 4. Academy Trophy Vault Door  ──► MatchHistoryScreen         │
│           ├── 5. Camera Viewfinder Door     ──► InteractiveInstructions    │
│           └── 6. Box Office Ticket Door     ──► SceneVaultScreen           │
│                                     │                                      │
│  Layer 4: Floating Glassmorphic "LIVE WIRE" Broadcast Chyron Ticker        │
└────────────────────────────────────────────────────────────────────────────┘
```

### Interactive Component & State Mapping

- **Interactive 3D Holographic Marquee**:
  - Continuous `AnimationController` drives dual sweeping searchlight cones, a 24K gold/chrome `LinearGradient` `ShaderMask`, and a perimeter of 28 sequencing warm-white filament bulbs.
  - `onTap` triggers `HapticFeedback.heavyImpact()`, runs a 3D spring scale/tilt bounce, and injects a 10-flash frenzy burst into the paparazzi overlay painter.
- **First-Person 3D Red Carpet & Stanchion Haptic Choreography**:
  - Projects 8 pairs of 3D gold stanchion posts and catenary velvet ropes along perspective vanishing lines.
  - Tracks `scrollOffset` and scroll delta velocity: crossing each virtual stanchion threshold fires `HapticFeedback.selectionClick()` and boosts camera flash spawn rate.
- **Interactive3DDoorCard Wrapper & Six Bespoke Doors**:
  - Tracks local touch coordinates via `GestureDetector` (`onPanDown`, `onPanUpdate`, `onPanEnd`, `onTapCancel`, `onTap`) to compute normalized `dx, dy` in `[-1.0, 1.0]`, applying `rotateX(-dy * 0.21)` and `rotateY(dx * 0.21)` ($\approx 12^\circ$) plus a moving radial specular highlight over a blurred glassmorphic surface.
  - Preserves every existing navigation callback (`_openCallSheetAndNavigate`, `LateNightAfterHoursScreen`, `MatchHistoryScreen`, `InteractiveInstructionsScreen`, `SceneVaultScreen`, audio mute toggle, and cloud credentials sheet).
