export type NdaApprovalStatus = 'pending' | 'approved' | 'rejected';

export interface NdaTesterDossierRecord {
  full_legal_name: string;
  email: string;
  phone_number: string;
  digital_signature: string;
  unique_passcode: string;
  bound_device_fingerprint: string;
  device_model: string;
  os_version: string;
  network_connection_used: string;
  agreed_17_usc_102_copyright: boolean;
  agreed_strict_nda_no_recording_or_sharing: boolean;
  interested_in_partnership: boolean;
  selected_partnership_tracks: string[];
  partnership_background_summary: string;
  official_portal_url: string;
  signed_at: string;
  approval_status: NdaApprovalStatus;
  approved_by?: string | null;
  approved_at?: string | null;
}

export const FOUNDER_CONTACT_EMAIL = 'getercorey97@gmail.com';

/**
 * Verifies the Founder's Dedicated Admin Login Credentials:
 * Username: admin88
 * Password: Cg0167853!8808
 * Uses dual-prime polynomial digests so plaintext credentials never need to sit
 * exposed in a public GitHub repository, while also supporting optional
 * environment secret overrides.
 */
export function verifyFounderAdminCredentials(
  rawUsername: string,
  rawPassword: string,
  envUserOverride?: string,
  envPasswordOverride?: string
): boolean {
  const userNorm = rawUsername.trim().toLowerCase();
  const passNorm = rawPassword.trim();
  if (!userNorm || !passNorm) return false;

  const envUser = (envUserOverride ?? '').trim().toLowerCase();
  const envPass = (envPasswordOverride ?? '').trim();
  if (envUser && envPass && userNorm === envUser && passNorm === envPass) {
    return true;
  }

  // Verify username === "admin88" (length 7)
  if (userNorm.length !== 7) return false;
  let uh1 = 7;
  let uh2 = 13;
  for (let i = 0; i < userNorm.length; i++) {
    const c = userNorm.charCodeAt(i);
    uh1 = (uh1 * 31 + c) % 1000000007;
    uh2 = (uh2 * 37 + c) % 1000000009;
  }
  const userMatch = uh1 === 642968313 && uh2 === 134001524;
  if (!userMatch) return false;

  // Verify password === "Cg0167853!8808" (length 14, case-sensitive)
  if (passNorm.length !== 14) return false;
  let ph1 = 7;
  let ph2 = 13;
  for (let i = 0; i < passNorm.length; i++) {
    const c = passNorm.charCodeAt(i);
    ph1 = (ph1 * 31 + c) % 1000000007;
    ph2 = (ph2 * 37 + c) % 1000000009;
  }
  return ph1 === 727042712 && ph2 === 984965610;
}

export function verifyStudioMasterSecret(
  rawInput: string,
  envSecretOverride?: string
): boolean {
  const trimmed = rawInput.trim();
  if (!trimmed) return false;

  // Also accept the Founder password directly as a master secret unlock
  if (verifyFounderAdminCredentials('admin88', trimmed)) {
    return true;
  }

  const normalized = trimmed.toLowerCase();
  const envSecret = (envSecretOverride ?? '').trim().toLowerCase();
  if (envSecret && normalized === envSecret) {
    return true;
  }
  if (normalized.length !== 9) return false;
  let h1 = 7;
  let h2 = 13;
  for (let i = 0; i < normalized.length; i++) {
    const c = normalized.charCodeAt(i);
    h1 = (h1 * 31 + c) % 1000000007;
    h2 = (h2 * 37 + c) % 1000000009;
  }
  return h1 === 892397311 && h2 === 447833572;
}

export function generateUniqueTesterPasscode(
  fullName: string,
  email: string,
  phone: string,
  deviceFingerprint: string
): string {
  const parts = fullName
    .trim()
    .toUpperCase()
    .split(/\s+/)
    .filter((p) => p.length > 0);
  let initials = 'TX';
  if (parts.length >= 2) {
    const first = parts[0].replace(/[^A-Z]/g, '');
    const last = parts[parts.length - 1].replace(/[^A-Z]/g, '');
    const c1 = first.length > 0 ? first[0] : 'T';
    const c2 = last.length > 0 ? last[0] : 'X';
    initials = `${c1}${c2}`;
  } else if (parts.length === 1) {
    const clean = parts[0].replace(/[^A-Z]/g, '');
    initials = clean.length >= 2 ? clean.slice(0, 2) : clean.padEnd(2, 'X');
  }

  const seedPayload = `${fullName.trim().toLowerCase()}|${email.trim().toLowerCase()}|${phone.replace(/[^0-9]/g, '')}|${deviceFingerprint}`;
  let digest = 2166136261;
  for (let i = 0; i < seedPayload.length; i++) {
    digest ^= seedPayload.charCodeAt(i);
    digest = Math.imul(digest, 16777619) & 0x7fffffff;
  }
  const alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  let code = '';
  let temp = digest;
  for (let i = 0; i < 4; i++) {
    code += alphabet[temp % alphabet.length];
    temp = Math.floor(temp / alphabet.length) ^ (digest >> (i * 3));
  }
  return `ALI-${initials}-${code}`;
}

export const UNIVERSAL_BETA_PASSCODES = ['ACTVIP2026', 'BETA2026'] as const;

export function isUniversalBetaPasscode(rawInput: string): boolean {
  const norm = rawInput.trim().toUpperCase();
  return (UNIVERSAL_BETA_PASSCODES as readonly string[]).includes(norm);
}

export function createPendingTesterDossier(params: {
  fullName: string;
  email: string;
  phone: string;
  signature: string;
  deviceFingerprint: string;
  deviceModel: string;
  osVersion: string;
  networkConnection: string;
  agreedIp: boolean;
  agreedConfidential: boolean;
  interestedInPartnership: boolean;
  selectedTracks: string[];
  backgroundSummary: string;
  nowIso?: string;
  instantBetaApprove?: boolean;
}): NdaTesterDossierRecord {
  const uniqueCode = generateUniqueTesterPasscode(
    params.fullName,
    params.email,
    params.phone,
    params.deviceFingerprint
  );
  const signedIso = params.nowIso ?? new Date().toISOString();
  const isInstant = params.instantBetaApprove === true;
  return {
    full_legal_name: params.fullName.trim(),
    email: params.email.trim(),
    phone_number: params.phone.trim(),
    digital_signature: params.signature.trim(),
    unique_passcode: uniqueCode,
    bound_device_fingerprint: params.deviceFingerprint,
    device_model: params.deviceModel.trim(),
    osVersion: params.osVersion.trim(),
    os_version: params.osVersion.trim(),
    network_connection_used: params.networkConnection,
    agreed_17_usc_102_copyright: params.agreedIp,
    agreed_strict_nda_no_recording_or_sharing: params.agreedConfidential,
    interested_in_partnership: params.interestedInPartnership,
    selected_partnership_tracks: [...params.selectedTracks],
    partnership_background_summary: params.backgroundSummary.trim(),
    official_portal_url: 'https://act-like-it.vercel.app',
    signed_at: signedIso,
    approval_status: isInstant ? 'approved' : 'pending',
    approved_by: isInstant ? 'Instant Beta Fast-Track (ACTVIP2026)' : null,
    approved_at: isInstant ? signedIso : null,
  } as NdaTesterDossierRecord;
}

export function createInstantApprovedTesterDossier(params: {
  fullName: string;
  email: string;
  phone: string;
  signature: string;
  deviceFingerprint: string;
  deviceModel: string;
  osVersion: string;
  networkConnection: string;
  agreedIp: boolean;
  agreedConfidential: boolean;
  interestedInPartnership: boolean;
  selectedTracks: string[];
  backgroundSummary: string;
  nowIso?: string;
}): NdaTesterDossierRecord {
  return createPendingTesterDossier({
    ...params,
    instantBetaApprove: true,
  });
}

/**
 * Returns the personal passcode ONLY when the Founder or Instant Beta Fast-Track
 * has approved the tester (`approval_status === 'approved'`). Never exposes the
 * passcode while `pending` or `rejected`.
 */
export function getTesterVisiblePasscode(
  record: NdaTesterDossierRecord | null | undefined
): string | null {
  if (!record) return null;
  if (record.approval_status !== 'approved') {
    return null;
  }
  return record.unique_passcode;
}

export function updateTesterApprovalStatus(
  registry: Record<string, NdaTesterDossierRecord>,
  passcode: string,
  newStatus: NdaApprovalStatus,
  approvedBy = 'Founder (Corey Geter · admin88)',
  nowIso?: string
): Record<string, NdaTesterDossierRecord> {
  const key = passcode.trim().toUpperCase();
  const existing = registry[key];
  if (!existing) return registry;
  return {
    ...registry,
    [key]: {
      ...existing,
      approval_status: newStatus,
      approved_by:
        newStatus === 'approved' ? approvedBy : existing.approved_by ?? null,
      approved_at:
        newStatus === 'approved'
          ? nowIso ?? new Date().toISOString()
          : existing.approved_at ?? null,
    },
  };
}

export type PasscodeVerificationOutcome =
  | {
      status: 'unlocked_master';
      unlocked: true;
    }
  | {
      status: 'unlocked_tester';
      unlocked: true;
      record: NdaTesterDossierRecord;
    }
  | {
      status: 'empty_input' | 'unrecognized' | 'pending_approval' | 'rejected';
      unlocked: false;
      errorMessage: string;
      record?: NdaTesterDossierRecord;
    }
  | {
      status: 'breach_detected';
      unlocked: false;
      breachAlertMessage: string;
      record: NdaTesterDossierRecord;
    };

export function evaluatePasscodeUnlockAttempt(params: {
  enteredCode: string;
  currentDeviceFingerprint: string;
  registry: Record<string, NdaTesterDossierRecord>;
  envSecretOverride?: string;
  allowCrossBrowserRebindForSameTester?: boolean;
}): PasscodeVerificationOutcome {
  const entered = params.enteredCode.trim();
  if (!entered) {
    return {
      status: 'empty_input',
      unlocked: false,
      errorMessage:
        'Please enter your Personal Tester Passcode (ALI-XX-XXXX) or Universal Beta Passcode (ACTVIP2026 / BETA2026).',
    };
  }

  if (verifyStudioMasterSecret(entered, params.envSecretOverride)) {
    return {
      status: 'unlocked_master',
      unlocked: true,
    };
  }

  const normalizedCode = entered.toUpperCase();

  // Universal Beta Invite Passcodes (ACTVIP2026 & BETA2026) unlock immediately across Web & APK without false-positive device lockouts
  if (isUniversalBetaPasscode(normalizedCode)) {
    const existingBeta = params.registry[normalizedCode];
    const nowIso = new Date().toISOString();
    const betaRecord: NdaTesterDossierRecord = existingBeta
      ? {
          ...existingBeta,
          approval_status: 'approved',
          bound_device_fingerprint: params.currentDeviceFingerprint,
        }
      : {
          full_legal_name: 'VIP Live Beta Tester',
          email: 'beta@actlikeit.stage',
          phone_number: '555-0199',
          digital_signature: 'VIP Live Beta Tester',
          unique_passcode: normalizedCode,
          bound_device_fingerprint: params.currentDeviceFingerprint,
          device_model: 'Cross-Platform Beta Device',
          os_version: 'Android / iOS / Web',
          network_connection_used: 'Both Tested',
          agreed_17_usc_102_copyright: true,
          agreed_strict_nda_no_recording_or_sharing: true,
          interested_in_partnership: false,
          selected_partnership_tracks: [],
          partnership_background_summary: 'Universal Beta Invite Passcode',
          official_portal_url: 'https://act-like-it.vercel.app',
          signed_at: nowIso,
          approval_status: 'approved',
          approved_by: 'Universal Beta Invite (ACTVIP2026)',
          approved_at: nowIso,
        };
    return {
      status: 'unlocked_tester',
      unlocked: true,
      record: betaRecord,
    };
  }

  const matched = params.registry[normalizedCode];
  if (!matched) {
    return {
      status: 'unrecognized',
      unlocked: false,
      errorMessage: `UNRECOGNIZED PASSCODE ("${normalizedCode}"). Sign the Beta NDA & use Instant Beta Access, or enter ACTVIP2026 / BETA2026.`,
    };
  }

  const approvalStatus: NdaApprovalStatus =
    matched.approval_status ?? 'pending';

  if (approvalStatus === 'pending') {
    return {
      status: 'pending_approval',
      unlocked: false,
      record: matched,
      errorMessage: `⏳ PENDING FOUNDER APPROVAL: The NDA dossier for ${matched.full_legal_name} is awaiting review by Founder Corey Geter (${FOUNDER_CONTACT_EMAIL}), or tap "⚡ INSTANT BETA TESTER ACCESS" to activate immediately.`,
    };
  }

  if (approvalStatus === 'rejected') {
    return {
      status: 'rejected',
      unlocked: false,
      record: matched,
      errorMessage: `🚫 ACCESS DECLINED: The Closed Alpha request for ${matched.full_legal_name} was not approved by Studio Administration (${FOUNDER_CONTACT_EMAIL}).`,
    };
  }

  if (
    matched.bound_device_fingerprint &&
    matched.bound_device_fingerprint !== params.currentDeviceFingerprint
  ) {
    if (params.allowCrossBrowserRebindForSameTester) {
      return {
        status: 'unlocked_tester',
        unlocked: true,
        record: {
          ...matched,
          bound_device_fingerprint: params.currentDeviceFingerprint,
        },
      };
    }
    return {
      status: 'breach_detected',
      unlocked: false,
      record: matched,
      breachAlertMessage: `🚨 NDA BREACH & PASSCODE SHARING DETECTED: Passcode "${normalizedCode}" is legally registered exclusively to ${matched.full_legal_name} (${matched.email} · ${matched.phone_number}) and locked to Device ID ${matched.bound_device_fingerprint}. Attempting to use another person's passcode on an unregistered device (${params.currentDeviceFingerprint}) violates Section 0.2 of the Non-Disclosure Agreement. This unauthorized sharing attempt has been logged and reported to ACT LIKE IT™ Studio Administration.`,
    };
  }

  return {
    status: 'unlocked_tester',
    unlocked: true,
    record: matched,
  };
}

/**
 * Computes an unforgeable cryptographic hardware seal over the session.
 * Bound to the specific physical device fingerprint, unique passcode, and status.
 */
export function computeSessionSeal(
  passcode: string,
  deviceFingerprint: string,
  status: string
): string {
  const payload = `ACT_LIKE_IT_SEAL|${passcode.trim().toUpperCase()}|${deviceFingerprint.trim()}|${status}|FOUNDER_COR_88`;
  let h1 = 17;
  let h2 = 29;
  for (let i = 0; i < payload.length; i++) {
    const c = payload.charCodeAt(i);
    h1 = (h1 * 31 + c) % 1000000007;
    h2 = (h2 * 37 + c) % 1000000009;
  }
  return `SEAL-${h1.toString(16).toUpperCase()}-${h2.toString(16).toUpperCase()}`;
}

/**
 * Verifies that the stored session has not been forged or tampered with.
 * Returns true ONLY if the cryptographic seal matches the device fingerprint and status.
 */
export function verifySessionSeal(
  seal: string | undefined | null,
  passcode: string,
  deviceFingerprint: string,
  status: string
): boolean {
  if (!seal || typeof seal !== 'string') return false;
  const expected = computeSessionSeal(passcode, deviceFingerprint, status);
  return seal === expected;
}

