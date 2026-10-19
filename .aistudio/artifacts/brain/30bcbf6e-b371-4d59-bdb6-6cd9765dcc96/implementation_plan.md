# Act Like It — Synthesized 4-Module Master Plan (2.5D Cell-Shaded First-Person Ecosystem)

## Critical Aesthetic, Infrastructure & Non-Destructive Guardrails
- **Target Device & Build Pipeline Lockdown**: Samsung Galaxy S26 Ultra via "Sync to GitHub". `.github/workflows/build_apk.yml` (`flutter clean` + `compileSdk = 36` overrides), `pubspec.yaml`, `OfflineManager` state, LiveKit WebRTC SFU routing, and all existing tables and RLS policies remain **100% untouched and protected**.
- **Additive-Only Supabase Updates**: Only non-destructive, additive `upsert` operations on `profiles` (for new avatar archetype & casting telemetry fields) and safe additive schema columns (`ALTER TABLE ... ADD COLUMN IF NOT EXISTS`) are permitted—zero modifications or deletions of existing tables or RLS policies.
- **Central `assets/app_logo.png` Brand Centerpiece**: Build a reusable, interactive 2.5D cell-shaded logo showcase widget (`ActLikeItBrandCenterpiece`) around `assets/app_logo.png` featuring kinetic spotlight sweeps, press-and-tilt parallax, cel-shaded halftone rim lighting, and graceful fallback rendering if the image asset is still being synced—serving as the hero centerpiece across the Cinematic Opening and Dual-Track Auth flows.
- **2.5D Cell-Shaded Aesthetic ("The Boondocks" Style)**: All characters, UI accents, and transitions use a gritty, high-contrast, anime-influenced 2.5D cell-shaded art style with heavy ink outlines (`3.0px`–`4.0px` jet-black strokes), dramatic cel-shaded shadow blocks, kinetic speed/action lines, and an urban-satirical Hollywood premiere atmosphere on top of `#07090E` obsidian backgrounds and neon accents.
- **Persistent First-Person POV Ecosystem**: The player experiences the studio lot from a first-person camera perspective, with all **14 Avatar Archetypes** physically populating the foreground and background across the intro, Red Carpet doors, and transitions.

---

## Module 1: Cell-Shaded Cinematic Opening, `assets/app_logo.png` Hero & Dual-Track Auth (`lib/ui/intro_cinematic.dart` & `lib/auth/login_screen.dart`)
- **Central `assets/app_logo.png` Interactive Brand Centerpiece**:
  - Displayed with 60fps scale-and-glow entrance, interactive touch-tilt reactivity, cel-shaded gold aura, and comic speed-line bursts during both the Cinematic Opening climax and the Dual-Track Auth header.
- **Launch Flow & Fast-Skip**:
  - Plays automatically on launch with a high-contrast cel-shaded **"FAST-SKIP TO RED CARPET"** glass pill button for returning actors.
- **60fps First-Person Cell-Shaded Red Carpet Walk**:
  - First-person camera bobbing and stepping down a chaotic, cell-shaded Hollywood Red Carpet with kinetic action lines, paparazzi flash bursts, and the **14 Avatar Archetypes** dynamically interacting in 2.5D anime-inspired cel shading.
- **"CUT!" Clapperboard Smash Transition to Auth**:
  - The **Director** archetype steps into the lens, yells **"CUT!"**, and slaps a heavy cell-shaded clapperboard directly into the camera lens, cutting hard to black and revealing the `assets/app_logo.png` centerpiece on the Auth & Casting screen.
- **Dual-Track Auth & Additive Supabase Telemetry**:
  - **Track A ("Claim Your Star")** and **Track B ("Sneak Backstage")** with the interactive 4-step Casting Questionnaire and 14-Archetype Selector rendered in 2.5D cell-shaded style, performing non-destructive additive `upsert` writes of avatar and casting telemetry to Supabase `profiles`.

---

## Module 2: First-Person Ecosystem & The Cutting Room Floor (`lib/dashboard_marquee.dart`, `lib/lobby.dart`, & `lib/social/cutting_room_feed.dart`)
- **Persistent 14-Archetype First-Person Red Carpet**:
  - Preserves all 6 Red Carpet Doors while embedding the 14 cell-shaded characters directly into the first-person environment (e.g., **Paparazzi** snapping blinding flashbulbs along the ropes, **Mob Boss** in a sharp cel-shaded pinstripe suit guarding Door 2, **Method Actor** rehearsing by the Scene Vault).
- **First-Person Silver Elevator Transition (`The Cutting Room Floor` Portal)**:
  - Positioned on the Red Carpet with a neon club sign (`"THE CUTTING ROOM FLOOR"`), velvet rope, and two cell-shaded security guards.
  - On tap: First-person POV animation where the guards press the call button, unhook the red velvet rope, the user steps inside the brushed-silver elevator, and the sliding metal doors close—reflecting the player's chosen 2.5D cell-shaded avatar in the polished chrome—before sliding open into the social feed.
- **The Cutting Room Floor (`lib/social/cutting_room_feed.dart`)**:
  - Vertical full-screen swipeable audition feed (`PageView.builder`) with auto-looping performances, **5-to-1 Golden Star Rating Box**, **Director's Comment Stamp**, and **Native Viral Share Trigger** (`Share.share`).

---

## Module 3: Bespoke Transition Engine & Live Audition (`lib/ui/transitions.dart` & `lib/webrtc_manager.dart`)
- **Bespoke First-Person Transition Engine (`lib/ui/transitions.dart`)**:
  - **Door 1 (6-Digit Room / Green Room)**: Heavy soundstage door slams shut directly in the user's face with comic impact lines; the crimson **"ON AIR"** light flares overhead before fading into the Green Room.
  - **Door 2 (18+ After-Hours Lounge)**: The cell-shaded **Mob Boss** unhooks the crimson velvet rope and exhales a thick plume of cel-shaded cigar smoke across the camera lens to wipe into the After-Hours lobby.
  - **Scene Vault (Doors 3–6 / Categories)**: A vintage press flashbulb pops directly into the camera lens with high-contrast halftone rays, triggering a white-out optical fade into the vault.
- **The Live Audition Engine (`lib/webrtc_manager.dart`)**:
  - Preserves all LiveKit WebRTC SFU routing intact while enforcing safe camera layout (`math.max(4.0, constraints.maxHeight)` before `.clamp()`), the **"3... 2... 1... ACTION!"** clapperboard pre-roll countdown, compact lower-third **Dynamic Teleprompter**, **10-Second Late-Night Improvisation Twist**, and **Co-Star Split-Screen Duet Mode**.

---

## Module 4: Gamified AI Verdict & Anime Impact Reveal (`lib/judging_engine.dart`)
- **Explosive Anime Freeze-Frame Verdict Reveal**:
  - Replaces the static envelope opening with a high-energy **Boondocks / Dragon Ball Z style impact climax**: radial comic speed lines, chromatic freeze-frame flash, and heavy cell-shaded typography slamming the final score onto the screen.
- **Staggered 3-Pillar Score Counters & AI Director's Critique**:
  - Staggered count-up animations for **Emotional Commitment**, **Line Accuracy & Pacing**, and **Stage Presence & Physicality**, paired with the regex-sanitized Gemini **AI Director's Critique Card**, real recorded MP4 loop playback, and non-destructive additive telemetry upserts.
