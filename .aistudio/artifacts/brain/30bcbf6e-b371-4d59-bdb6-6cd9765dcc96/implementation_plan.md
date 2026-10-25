# Manual Founder Approval for Closed Alpha NDA & Tester Gate

## Overview
Because the repository is public on GitHub, we will add a **Mandatory Founder Approval Gate** to the existing Closed Alpha NDA & Partnership Dossier workflow while preserving all existing legal fields, co-founder/partnership track selections, device hardware fingerprinting, and anti-sharing breach detection.

---

## 1. Tester NDA Submission & Hidden Passcode Flow
- **Preserve All Existing NDA & Partner Fields**: Sections 0 and 1 (Full Legal Name, Email, Phone Number, Device Model, OS Version, Network Connection, IP/Copyright & Strict Confidentiality checkboxes, Digital Signature, and Co-Founder/Partnership Track selection) remain 100% unchanged.
- **Hidden Passcode Generation (`approval_status = 'pending'`)**:
  - When a prospective tester submits the signed NDA, their deterministic device-bound passcode (`ALI-XX-XXXX`) is generated and saved with `approval_status: 'pending'` in both the local registry and Supabase (`public.nda_tester_approvals` and `public.qa_feedback`), **but the passcode is NOT displayed to the tester**.
  - The Step 1 submit button will be updated to **"STEP 1: SIGN NDA & SUBMIT FOR FOUNDER APPROVAL"**.

---

## 2. Pending Approval Screen & Live Status Check
- Right after submitting their signed NDA, the tester sees a **Pending Founder Approval Card** displaying:
  - Confirmation that their signed NDA & Partnership Dossier has been recorded for their device (`DEVICE ID: DEV-...`).
  - Notice that access to **ACT LIKE IT™** requires manual approval by Studio Founder **Corey Geter** (`getercorey97@gmail.com`).
  - A **"🔄 CHECK APPROVAL STATUS"** button that queries Supabase and local state for their device/email approval status:
    - **If Still Pending**: Displays a clear status banner confirming their application is in the Founder Review Queue.
    - **If Approved (`approval_status = 'approved'`)**: Automatically reveals their unlocked `ALI-XX-XXXX` Personal Passcode (with one-click copy and auto-fill into Step 2) so they can immediately unlock the app.
    - **If Rejected/Revoked (`approval_status = 'rejected'`)**: Displays an access denied notice and blocks passcode login.
- **Step 2 Passcode Verification Guard**:
  - Even if someone guesses or obtains an `ALI-XX-XXXX` code, Step 2 (`Verify Personal Passcode & Unlock`) will verify that `approval_status == 'approved'` before unlocking (in addition to checking the existing device fingerprint lock).

---

## 3. Dual Admin Approval Workflow (In-App Admin Queue + Supabase Table)
- **In-App Founder Admin Queue (Unlocked via Studio Master Secret)**:
  - Adding a **"🛡️ 3. FOUNDER ADMIN APPROVAL QUEUE"** mode/panel inside the NDA Gate (and accessible after unlocking with your Studio Master Secret).
  - Entering your Studio Master Secret opens the **Founder Tester Approval Queue**, listing all submitted NDA dossiers (Name, Email, Phone, Device ID, Partner Track interest, Signed Timestamp, Assigned `ALI-XX-XXXX` code, and current Status: `PENDING` / `APPROVED` / `REJECTED`).
  - Includes one-click **"✅ APPROVE & ISSUE PASSCODE"**, **"🚫 REJECT / REVOKE"**, and **"📋 COPY TESTER PASSCODE"** actions so you can either let them click "Check Approval Status" on their screen or text/email them their approved `ALI-XX-XXXX` code directly.
- **Supabase Database Table (`supabase/migrations/20261025000003_nda_tester_approvals.sql`)**:
  - Creates a dedicated `public.nda_tester_approvals` table with columns: `id`, `full_legal_name`, `email`, `phone_number`, `digital_signature`, `unique_passcode`, `bound_device_fingerprint`, `device_model`, `os_version`, `network_connection_used`, `interested_in_partnership`, `selected_partnership_tracks`, `partnership_background_summary`, `approval_status` (`'pending' | 'approved' | 'rejected'`), `approved_at`, and `created_at`.
  - Allows you to flip `approval_status` to `'approved'` directly inside the Supabase Table Editor OR from the in-app Founder Admin Queue.

---

## Files to Create / Update
1. `supabase/migrations/20261025000003_nda_tester_approvals.sql` — Additive Supabase table & RLS policies for `public.nda_tester_approvals`.
2. `lib/auth/nda_tester_gate.dart` — Update Flutter NDA Gate to hide passcodes until approved, add the Pending Approval screen with "Check Approval Status" & Founder contact info, enforce approval check on unlock, and add the Founder Admin Approval Queue panel.
3. `src/App.tsx` — Synchronize the React standalone preview NDA Gate with the exact same Pending Approval screen, "Check Approval Status" button, and Founder Admin Approval Queue.
4. `src/utils/part1Specs.ts` — Keep the embedded workspace code catalog synced with the updated Flutter & SQL definitions.
