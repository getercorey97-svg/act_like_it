# Act Like It — 2.5D Puppet Rig, Navigation Flow & S26 Ultra Layout Overhaul Plan

## Confirmed Decisions & Surgical Lockdowns
- **Character Spotlight & Avatar Equip Flow**: Tapping any 2.5D character on the Red Carpet or Doors opens a **full-card modal with an equip button and live 5-layer animated preview** (zero text truncation).
- **Soundstage Ambient Atmosphere**: Entering the Main Dashboard **auto-plays a warm premiere ambient loop at 35% default volume**, replacing the harsh 8-bit loop, respecting the volume slider in real time, and pausing immediately when navigating away.
- **Green Room Solo & AI Co-Star Population**: New host lobbies start cleanly at **Cast: 1/8** using the player's saved `@handle`, with an **"+ Add AI Co-Star"** button that **adds 1 ready AI Co-Star per tap up to 8 total cast**.
- **Intro Cinematic Red Carpet & Spotlight Pacing**: Replace the drifting hollow colored rectangles on the Red Carpet with the articulated 5-layer `BoondocksCharacterRig` characters, slow the character spotlight card cycle from `0.5s` to `2.5s` per character so users can read each bio, and wrap `"FAST-SKIP TO RED CARPET"` in `FittedBox` so it never clips to `"RED CA"`.
- **Onboarding Stepper Tabs & Perforated Tickets**: Shorten the 3 top stepper tabs to `"1. ERAS"`, `"2. STRENGTHS"`, and `"3. VIP PASS"` inside `FittedBox` so they never truncate, and apply the perforated movie ticket `CustomClipper` (semicircular side notches + dashed tear line) to the Era and Archetype cards as well.
- **Bidirectional Silver Elevator Transition**: Ensure popping/exiting `"THE CUTTING ROOM FLOOR"` reverses the Silver Elevator doors cleanly rather than triggering the Velvet Rope stanchion graphic.
- **WebRTC Release Build Safety**: While hiding the Teleprompter script during `_isPreRolling`, strictly preserve `VideoViewFit.cover` (never `RTCVideoViewObjectFit`) and keep all safe `.clamp()` math guards (`math.max(4.0, constraints.maxHeight)`) intact so the release APK compiles with zero errors.

---

## System Architecture & Navigation Flow

```
+-----------------------------------------------------------------------------------+
|                        2.5D CINEMATIC INTRO & DUAL-TRACK AUTH                     |
|  • 5-Layer Articulated BoondocksCharacterRig on Red Carpet (no hollow boxes)      |
|  • 2.5s Character Spotlight Cycle + FittedBox "FAST-SKIP TO RED CARPET" Pill      |
|  • "1. ERAS" / "2. STRENGTHS" / "3. VIP PASS" Tabs + Perforated Ticket Clipper    |
|  • Unclipped Brand Header + Friendly Auth Errors + Fast Year Wheel/Stepper        |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                     FIRST-PERSON PAPARAZZI RED CARPET DASHBOARD                   |
|  • FittedBox Marquee ("2.5D GRAND PREMIERE SOUNDSTAGE") + Inset Gold Bulbs        |
|  • Warm Premiere Ambient Audio (35% default) + Locked Developer Diagnostics Keys  |
|  • 14 Interactive 5-Layer Character Rigs on Carpet & Doors -> Full Spotlight Card |
|  • Clipped "LIVE WIRE |" Chyron ("THE GOTHAM INTERROGATION") + 96px Bottom Pad    |
+------------+----------------------------+----------------------------+------------+
             |                            |                            |
   [Create / Quick Play]         [Silver Elevator]             [Doors 1–6 & Vault]
             |                    (Forward & Pop)                      |
             v                            v                            v
+-------------------------+  +-------------------------+  +-------------------------+
|  SINGLE CALL SHEET FLOW |  | THE CUTTING ROOM FLOOR  |  | BESPOKE 2.5D TRANSITIONS|
|  • Sticky "ROLL CAMERA" |  | • SafeArea Elevator Top |  | • 3D Hinged Clapperboard|
|  • "1 PLAYER" Grammar   |  | • Right Rail Below Pill |  | • 3D Stanchion & Smoke  |
|  • Direct 6-Digit Gen   |  | • Bright Cyan Share     |  | • Radial Flashbulb Pop  |
+------------+------------+  | • SafeArea Stamp Sheet  |  | • Perforated Tickets    |
             |               +-------------------------+  +------------+------------+
             v                                                         |
+----------------------------------------------------------------------+------------+
|                    STUDIO GREEN ROOM & LIVE AUDITION SOUNDSTAGE                   |
|  • Saved @Handle Sync · Cast 1/8 Default · "+ Add AI Co-Star" (1 per tap up to 8) |
|  • Pre-Roll Hides Teleprompter Script · Preserves VideoViewFit.cover & .clamp()   |
+-----------------------------------------------------------------------------------+
```

---

## Part 1: 5-Layer Articulated 2.5D Puppet Rig (`BoondocksCharacterRig`) & Intro Polish
- **60fps Procedural 5-Layer Character Rig**:
  1. **Secondary Hair/Coat Silhouette Layer**: Trails torso movement with a `0.4 rad` phase delay for fluid secondary motion.
  2. **Breathing Torso & Shoulders Layer**: Smooth vertical bobbing and chest expansion driven by `sin(t * 2.5)` with sharp cel-shaded shadow blocks.
  3. **Expressive Head & Jaw Layer**: Dynamic `rotateZ` head tilt, sharp cel-shaded jawline shadows, and animated talking/smirk mouth geometry.
  4. **Natural Blinking Eyes & Specular Eyewear Sweep**: Periodic `140ms` eye blink every `3.2s` paired with a diagonal white specular lens sweep across sunglasses, visors, and monocles.
  5. **Active Foreground Prop Hand**: Signature animated prop per archetype (Auteur Director megaphone + soundwaves, Flashbulb Finn DSLR camera flare, Don Corleone Jr. glowing cigar + bezier smoke wisps, Julian Vane collar shadow + neon rain streaks, Valentina Lux adjusting starlet shades, etc.).
- **Intro Cinematic Red Carpet Upgrades**:
  - Replace the drifting hollow colored rectangles on the Red Carpet with live 5-layer `BoondocksCharacterRig` figures stationed along the velvet ropes.
  - Slow the spotlight bio card cycle to `2.5s` per character so each archetype is readable.
  - Wrap `"FAST-SKIP TO RED CARPET"` inside `FittedBox(fit: BoxFit.scaleDown)` so it never truncates on the Samsung Galaxy S26 Ultra.

---

## Part 2: Main Dashboard, Settings Modal & Red Carpet Character Placement
- **Secure Developer Diagnostics & Audio Defaults**:
  - Collapse raw API keys (`GEMINI_API_KEY`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `LIVEKIT_URL`) inside a locked `"Developer Diagnostics (Locked)"` accordion with `obscureText: true` by default.
  - Set `"Soundstage Master Volume"` default to `0.35` (35%) and wire it directly to a warm, low-volume premiere ambient atmosphere loop that pauses immediately when leaving the dashboard or entering a live camera room.
- **Marquee & Red Carpet Visual Cleanup**:
  - Wrap `"2.5D GRAND PREMIERE SOUNDSTAGE"` in `FittedBox(fit: BoxFit.scaleDown)` and inset all marquee lightbulbs cleanly inside the gold frame.
  - Remove the `"FIRST-PERSON POV · 14 CELL-SHADED ARCHETY..."` meta-header and the cramped horizontal avatar strip; station the 2.5D character rigs directly on the Red Carpet and beside the 6 Doors, opening the full-card bio & avatar equip modal on tap.
  - Update `"The Cutting Room Floor"` portal subtitle to `"Step into the VIP Silver Elevator to watch, rate, and roast top audition reels."`
  - Replace copyrighted ticker text with `"THE GOTHAM INTERROGATION"`, clip scrolling ticker text strictly to the right of `"LIVE WIRE |"`, and add `96px` bottom scroll padding so the footer never obscures cards.

---

## Part 3: Single Call Sheet Flow & Green Room Enhancements
- **Eliminate the Double Call Sheet Loop**:
  - Tapping `"CREATE LOBBY / QUICK PLAY"` opens `"DIRECTOR'S CALL SHEET"` once; tapping `"ROLL CAMERA"` immediately generates the 6-digit room code and routes directly into the Studio Green Room (`VIP SOUNDSTAGE SET PASS`).
  - Tapping Door 1 (`"JOIN 6-DIGIT ROOM"`) routes straight to the 6-digit PIN entry and Green Room view without rendering a duplicate `"ACT LIKE IT"` marquee card.
- **Call Sheet & Green Room Polish**:
  - Fix singular/plural grammar (`"TOTAL CAST: 1 PLAYER"` vs `"PLAYERS"`), dock `"ROLL CAMERA"` in a sticky bottom footer outside the scroll view, and display a subtle scroll cue for the 5 studio toggles.
  - Hydrate the player's saved `@handle` across the Green Room, prevent `"GREEN ROOM"` AppBar title truncation, keep the `"STAGE LIVE"` pill inside card padding, start solo host lobbies at `Cast: 1/8` with an `"+ Add AI Co-Star"` button (adding 1 ready AI Co-Star per tap up to 8), and style `"Toggle Ready"` with a high-contrast gold/cyan border.

---

## Part 4: "The Cutting Room Floor" Social Feed Polish
- **Zero-Overlap Reel HUD & Action Column**:
  - Wrap top AppBar subtitle (`"REEL 1 OF 5 · SWIPE UP"`) and the angled Director's Stamp banner in `FittedBox(fit: BoxFit.scaleDown)` so neither ever clips.
  - Position the right-side vertical action column (`STAMP` and `SHARE`) cleanly below the top `"LOOPING AUDITION REEL"` pill so `"STAMP"` never collides with the score badge, and style the `"SHARE"` icon in high-contrast cyan (`#0CB6D4`).
  - Replace duplicate-year copyrighted scene titles with `"THE GOTHAM INTERROGATION · ORIGINAL PARODY"`.
- **Star Rating Header & SafeArea Stamp Sheet**:
  - Separate `"5-TO-1 GOLDEN STAR RATING BOX"` and `"TAP TO RATE"` using `Flexible` + `FittedBox` inside a spaced row.
  - Wrap the `"STAMP DIRECTOR'S CRITIQUE ON REEL"` bottom sheet in `SafeArea` with keyboard-aware bottom padding and horizontally scrollable preset critique chips so nothing is clipped by the system navigation bar.

---

## Part 5: Bespoke Transitions, How to Play, Scene Vault, Auth & Camera Pre-Roll
- **Upgraded 2.5D First-Person Transitions**:
  - **Clapperboard (`CUT!` / `ACTION!`)**: Full-screen 3D hinged clapperboard (`Matrix4` perspective + diagonal zebra stripes) that physically swings shut with a `120ms` white impact flash.
  - **Silver Elevator (`Cutting Room Floor`)**: Wrapped in `SafeArea` so the top neon sign never overlaps the system status bar clock, with brushed-chrome sliding doors, a live 5-layer character reflection, and a dedicated reverse Silver Elevator door transition when popping/exiting `"THE CUTTING ROOM FLOOR"`.
  - **Velvet Rope (`After-Hours`)**: Two 3D brass stanchions with a physics-draped crimson velvet rope unhooking and rising cel-shaded cigar smoke clouds.
  - **Flashbulb Pop (`Scene Vault`)**: True `RadialGradient` white-gold camera flash bloom with expanding aperture blades.
- **How to Play, Scene Vault & Live Audition Pre-Roll**:
  - Make `"HOW TO PLAY"` slide cards vertically scrollable (`Expanded` + `SingleChildScrollView`) so all 3 feature boxes remain 100% visible.
  - Add a genuine perforated ticket `CustomClipper` with semicircular side notches, dashed tear lines, and `viewportFraction: 0.86` across both the Scene Vault and the Onboarding Era/Archetype tickets.
  - Hide the background Teleprompter script completely while the 10-second Pre-Roll countdown (`_isPreRolling`) is active, remove the duplicate top `"PRE-ROLL · 5s CUE"` pill, remove the bottom `"S26 Ultra Stage Active..."` status banner, and strictly preserve `VideoViewFit.cover` and all `.clamp()` math guards.
- **Auth & Onboarding Refinements**:
  - Shorten the 3 top onboarding stepper tabs to `"1. ERAS"`, `"2. STRENGTHS"`, and `"3. VIP PASS"` inside `FittedBox`.
  - Remove the half-sliced top marquee artifact on the login screen, add horizontal padding to the avatar selector strip, map raw `AuthApiException` strings to friendly messages that clear on tab switch, replace the birth-year slider with a fast wheel/stepper control, and pre-fill Step 3 of the onboarding questionnaire from initial sign-up data.
