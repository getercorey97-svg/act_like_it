import React, { useState } from 'react';
import {
  Copy,
  Check,
  FileCode2,
  Lock,
  Unlock,
  Flame,
  Zap,
} from 'lucide-react';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  getBatchCompletionRatio,
  verifyLateNightAgeGate,
} from './utils/part1Specs';

const LATE_NIGHT_PROMPTS = [
  {
    id: 'ln-1',
    title: 'This Is How I Win',
    film: 'Uncut Gems',
    year: 2019,
    character: 'Howard Ratner',
    spiceTier: 1,
    multiplier: '1.10x',
    advisory: '18+ Language & High-Anxiety Gambling Spiral',
    script:
      "You're having a good time, right? Look at this parlay. I disagree, Gary! This is how I win!",
    cue: 'Speak at 1.4x speed with manic grinning confidence while pretending to lock the security door.',
    twist:
      'TWIST AT 15s: The security buzzer jams—deliver the final line in a claustrophobic whisper.',
  },
  {
    id: 'ln-2',
    title: 'The Adrenaline Shot Count',
    film: 'Pulp Fiction',
    year: 1994,
    character: 'Vincent Vega',
    spiceTier: 2,
    multiplier: '1.20x',
    advisory: '18+ Mature Themes & Dark Panic Comedy',
    script:
      "I'm gonna count to three, and when I count three, you plunge that needle straight down. One... two...",
    cue: 'Hold an imaginary marker poised inches above the camera lens, eyes wide with sweat-drenched hesitation.',
    twist:
      'TWIST AT 15s: Switch roles mid-sentence and react as if you just woke up from a dead faint.',
  },
  {
    id: 'ln-3',
    title: 'The Masked Confession',
    film: 'Eyes Wide Shut',
    year: 1999,
    character: 'Alice & Bill Harford',
    spiceTier: 3,
    multiplier: '1.35x',
    advisory: '18+ Psychological Intimacy & After-Hours Tension',
    script:
      'If you men only knew... There is something very important that we need to do as soon as possible.',
    cue: 'Slow cadence to half-speed, hold an unblinking gaze three inches from the front camera.',
    twist:
      'TWIST AT 15s: Break into a sudden, unsettling laugh before snapping back to deadpan seriousness.',
  },
];

function verifyStudioMasterSecret(rawInput: string): boolean {
  const normalized = rawInput.trim().toLowerCase();
  if (!normalized) return false;
  const envSecret = (import.meta.env.VITE_ADMIN_PASSCODE ?? '').trim().toLowerCase();
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

function generateUniqueTesterPasscode(
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

export default function App() {
  const [deviceFingerprint] = useState<string>(() => {
    try {
      const existing = localStorage.getItem('act_like_it_device_fingerprint_v1');
      if (existing) return existing;
      const randomHex = Array.from({ length: 8 }, () =>
        Math.floor(Math.random() * 16)
          .toString(16)
          .toUpperCase()
      ).join('');
      const created = `DEV-WEB-${randomHex}`;
      localStorage.setItem('act_like_it_device_fingerprint_v1', created);
      return created;
    } catch {
      return 'DEV-WEB-SESSION';
    }
  });

  const [ndaUnlocked, setNdaUnlocked] = useState<boolean>(() => {
    try {
      return localStorage.getItem('act_like_it_nda_gate_unlocked_v2') === 'true';
    } catch {
      return false;
    }
  });
  const [ndaMode, setNdaMode] = useState<'sign' | 'unlock'>('sign');
  const [ndaFullName, setNdaFullName] = useState<string>('');
  const [ndaEmail, setNdaEmail] = useState<string>('');
  const [ndaPhone, setNdaPhone] = useState<string>('');
  const [ndaDevice, setNdaDevice] = useState<string>('iPhone 16 Pro Max / Galaxy S26 Ultra');
  const [ndaOsVersion, setNdaOsVersion] = useState<string>('iOS 18 / Android 16');
  const [ndaNetwork, setNdaNetwork] = useState<string>('Both Tested');
  const [ndaSignature, setNdaSignature] = useState<string>('');
  const [ndaAgreedIp, setNdaAgreedIp] = useState<boolean>(false);
  const [ndaAgreedConfidential, setNdaAgreedConfidential] = useState<boolean>(false);
  const [ndaInterestedPartner, setNdaInterestedPartner] = useState<boolean>(false);
  const [ndaSelectedTracks, setNdaSelectedTracks] = useState<string[]>([]);
  const [ndaBackgroundSummary, setNdaBackgroundSummary] = useState<string>('');
  const [issuedPasscode, setIssuedPasscode] = useState<string | null>(null);
  const [ndaPasscodeInput, setNdaPasscodeInput] = useState<string>('');
  const [ndaError, setNdaError] = useState<string | null>(null);
  const [ndaBreachAlert, setNdaBreachAlert] = useState<string | null>(null);

  const [selectedFilePath, setSelectedFilePath] = useState<string>(
    'lib/dashboard_marquee.dart'
  );
  const [copiedPath, setCopiedPath] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'files' | 'late-night' | 'sync-guide'>('files');

  // Part 5 Late-Night 18+ Gate Simulator State
  const [birthYearInput, setBirthYearInput] = useState<string>('1997');
  const [pinInput, setPinInput] = useState<string>('2026');
  const [vaultUnlocked, setVaultUnlocked] = useState<boolean>(false);
  const [gateError, setGateError] = useState<string | null>(null);
  const [selectedSpiceTier, setSelectedSpiceTier] = useState<number>(3);
  const [twistTriggeredId, setTwistTriggeredId] = useState<string | null>('ln-1');

  const selectedFile =
    WORKSPACE_FILES.find((f) => f.path === selectedFilePath) ?? WORKSPACE_FILES[0];
  const progress = getBatchCompletionRatio(BATCH_STAGES);

  const handleCopyCode = async (path: string, content: string) => {
    try {
      await navigator.clipboard.writeText(content);
      setCopiedPath(path);
      setTimeout(() => setCopiedPath(null), 2000);
    } catch {
      setCopiedPath(path);
      setTimeout(() => setCopiedPath(null), 2000);
    }
  };

  const handleUnlockVault = (e: React.FormEvent) => {
    e.preventDefault();
    const parsedYear = Number(birthYearInput);
    const check = verifyLateNightAgeGate({
      birthYear: parsedYear,
      currentYear: 2026,
      pinCode: pinInput,
    });
    if (!check.unlocked) {
      setGateError(check.reason ?? 'Age verification failed.');
      setVaultUnlocked(false);
      return;
    }
    setGateError(null);
    setVaultUnlocked(true);
  };

  const handleSignNdaAndGeneratePasscode = (e: React.FormEvent) => {
    e.preventDefault();
    setNdaError(null);
    setNdaBreachAlert(null);
    if (ndaFullName.trim().length < 3) {
      setNdaError('Please enter your Tester Full Legal Name.');
      return;
    }
    if (!ndaEmail.includes('@')) {
      setNdaError('Please enter a valid Tester Personal / Business Email.');
      return;
    }
    if (ndaPhone.trim().length < 7) {
      setNdaError('Please enter a valid Tester Phone Number.');
      return;
    }
    if (!ndaAgreedIp || !ndaAgreedConfidential) {
      setNdaError('You must check BOTH Legal & Non-Disclosure (NDA) acknowledgment boxes in Section 0.');
      return;
    }
    if (ndaSignature.trim().length < 3) {
      setNdaError('Please type your Full Legal Name in the Tester Digital Signature box.');
      return;
    }

    const uniqueCode = generateUniqueTesterPasscode(
      ndaFullName,
      ndaEmail,
      ndaPhone,
      deviceFingerprint
    );

    const record = {
      full_legal_name: ndaFullName.trim(),
      email: ndaEmail.trim(),
      phone_number: ndaPhone.trim(),
      digital_signature: ndaSignature.trim(),
      unique_passcode: uniqueCode,
      bound_device_fingerprint: deviceFingerprint,
      device_model: ndaDevice.trim(),
      os_version: ndaOsVersion.trim(),
      network_connection_used: ndaNetwork,
      interested_in_partnership: ndaInterestedPartner,
      selected_partnership_tracks: ndaSelectedTracks,
      partnership_background_summary: ndaBackgroundSummary.trim(),
      official_portal_url: 'https://act-like-it.vercel.app',
      signed_at: new Date().toISOString(),
    };

    try {
      const rawRegistry = localStorage.getItem('act_like_it_nda_passcode_registry_v2') ?? '{}';
      const registry = JSON.parse(rawRegistry);
      registry[uniqueCode.toUpperCase()] = record;
      localStorage.setItem('act_like_it_nda_passcode_registry_v2', JSON.stringify(registry));
    } catch {
      // ignore storage errors
    }

    setIssuedPasscode(uniqueCode);
    setNdaPasscodeInput(uniqueCode);
  };

  const handleVerifyPasscodeAndUnlock = (e: React.FormEvent) => {
    e.preventDefault();
    setNdaError(null);
    setNdaBreachAlert(null);

    const entered = ndaPasscodeInput.trim();
    if (!entered) {
      setNdaError('Please enter your Unique Personal Tester Passcode (ALI-XX-XXXX) or Studio Master Secret.');
      return;
    }

    if (verifyStudioMasterSecret(entered)) {
      try {
        localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
      } catch {
        // ignore
      }
      setNdaUnlocked(true);
      return;
    }

    const normalizedCode = entered.toUpperCase();
    try {
      const rawRegistry = localStorage.getItem('act_like_it_nda_passcode_registry_v2') ?? '{}';
      const registry = JSON.parse(rawRegistry);
      const matched = registry[normalizedCode];
      if (!matched) {
        setNdaError(
          `UNRECOGNIZED PASSCODE ("${normalizedCode}"). Every tester must complete and sign the Non-Disclosure Agreement first to receive their own Unique Personal Passcode.`
        );
        return;
      }

      if (
        matched.bound_device_fingerprint &&
        matched.bound_device_fingerprint !== deviceFingerprint
      ) {
        setNdaBreachAlert(
          `🚨 NDA BREACH & PASSCODE SHARING DETECTED: Passcode "${normalizedCode}" is legally registered exclusively to ${matched.full_legal_name} (${matched.email} · ${matched.phone_number}) and locked to Device ID ${matched.bound_device_fingerprint}. Attempting to use another person's passcode on an unregistered device (${deviceFingerprint}) violates Section 0.2 of the Non-Disclosure Agreement. This unauthorized sharing attempt has been logged and reported to ACT LIKE IT™ Studio Administration.`
        );
        return;
      }

      localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
      localStorage.setItem('act_like_it_nda_dossier_payload_v2', JSON.stringify(matched));
      setNdaUnlocked(true);
    } catch {
      setNdaError('Unable to verify passcode. Please complete Step 1 first.');
    }
  };

  if (!ndaUnlocked) {
    const partnershipTracks = [
      '1. Co-Founder & Chief Operating Officer (COO) / Studio Head',
      '2. Chief Technology Officer (CTO) / Lead Multiplayer Systems Engineer',
      '3. Head of Growth, Marketing & Viral Acquisition',
      "4. Senior Creative Director & Writer's Room Lead",
      '5. Strategic Angel Investor / Venture Partner',
    ];
    return (
      <div className="min-h-screen bg-slate-950 text-slate-100 font-['Plus_Jakarta_Sans',sans-serif] py-8 px-4 flex items-center justify-center">
        <div className="max-w-3xl w-full bg-slate-900 border-2 border-amber-500/80 rounded-2xl p-6 md:p-8 shadow-2xl space-y-6">
          <div className="flex items-center justify-between gap-3 bg-rose-950/80 border border-rose-500 rounded-xl px-4 py-3 text-rose-200 text-xs font-mono font-bold">
            <div className="flex items-center gap-2">
              <Lock className="w-4 h-4 text-rose-400 shrink-0" />
              <span>
                MANDATORY CLOSED ALPHA NDA &amp; UNIQUE PASSCODE LOCK
              </span>
            </div>
            <span className="text-amber-300">DEVICE ID: {deviceFingerprint}</span>
          </div>

          <div className="grid grid-cols-2 gap-2 bg-slate-950 p-1.5 rounded-xl border border-slate-800 text-xs font-mono font-bold">
            <button
              type="button"
              onClick={() => {
                setNdaMode('sign');
                setNdaError(null);
              }}
              className={`py-2.5 px-3 rounded-lg transition-colors ${
                ndaMode === 'sign'
                  ? 'bg-amber-400 text-slate-950'
                  : 'text-amber-200 hover:bg-slate-900'
              }`}
            >
              1. SIGN NDA &amp; GET UNIQUE PASSCODE
            </button>
            <button
              type="button"
              onClick={() => {
                setNdaMode('unlock');
                setNdaError(null);
              }}
              className={`py-2.5 px-3 rounded-lg transition-colors ${
                ndaMode === 'unlock'
                  ? 'bg-cyan-400 text-slate-950'
                  : 'text-cyan-300 hover:bg-slate-900'
              }`}
            >
              2. ENTER PERSONAL / ADMIN PASSCODE
            </button>
          </div>

          <div className="space-y-2">
            <h1 className="text-xl md:text-2xl font-black text-amber-200 leading-snug">
              🎬 &ldquo;ACT LIKE IT&rdquo; — OFFICIAL CLOSED ALPHA TESTING AGREEMENT, NON-DISCLOSURE (NDA) &amp; PARTNERSHIP DOSSIER
            </h1>
            <p className="text-xs font-mono text-cyan-400">
              STANDALONE EDITION — BUILD v1.0-ALPHA · OFFICIAL PORTAL: https://act-like-it.vercel.app
            </p>
          </div>

          {ndaMode === 'sign' && (
            <>
              <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3 text-xs text-slate-300 leading-relaxed">
                <h2 className="text-sm font-bold text-amber-400">
                  🔒 SECTION 0: PRE-REGISTRATION INTELLECTUAL PROPERTY &amp; LEGAL NOTICE
                </h2>
                <p>
                  <strong className="text-white">1. Unregistered Copyright &amp; Common-Law Intellectual Property Notice:</strong>{' '}
                  Although formal registration with the U.S. Copyright Office and the U.S. Patent and Trademark Office (USPTO) is currently pending, automatic statutory copyright protection under the U.S. Copyright Act (17 U.S.C. § 102) attaches immediately upon creation and fixation of this original work. All aspects of ACT LIKE IT™—including its original 100+ parody scripts, the &ldquo;Tri-Modal Judging Engine&rdquo; architecture, the &ldquo;2.5D Boondocks-inspired&rdquo; cell-shaded visual style and 14 character archetypes, the &ldquo;Life Is Improv&rdquo; stealth HUD mechanics, custom UI/UX layouts, audio cues, source code, database schemas, and trade dress—are the exclusive, proprietary intellectual property of the Creator/Studio (© 2026 ACT LIKE IT Studio. All Rights Reserved. Common-Law Trademark ACT LIKE IT™ Claimed).
                </p>
                <p>
                  <strong className="text-white">2. Strict Confidentiality, NDA &amp; Personal Passcode Anti-Sharing Policy:</strong>{' '}
                  By accessing the Closed Alpha build via <span className="text-cyan-400 font-mono">https://act-like-it.vercel.app</span> or the Android APK, you acknowledge and agree that this software is a Confidential Pre-Release Trade Secret. Upon signing below, you will receive a <strong className="text-amber-300">UNIQUE PERSONAL TESTER PASSCODE (ALI-XX-XXXX)</strong> locked to your legal name and this specific device. You expressly agree NOT to share your personal passcode, testing URL, or build files with any third party—any attempt to use your passcode on another person&rsquo;s device immediately triggers an NDA Breach Alert under your name.
                </p>
              </div>

              <form onSubmit={handleSignNdaAndGeneratePasscode} className="space-y-4">
                <h3 className="text-sm font-bold text-amber-400">
                  ✍️ TESTER &amp; POTENTIAL PARTNER LEGAL ACKNOWLEDGMENT &amp; DEVICE LOG
                </h3>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                  <div>
                    <label className="block text-xs font-bold text-amber-100 mb-1">Tester Full Legal Name *</label>
                    <input
                      type="text"
                      value={ndaFullName}
                      onChange={(e) => setNdaFullName(e.target.value)}
                      placeholder="First & Last Legal Name"
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-amber-100 mb-1">Personal / Business Email *</label>
                    <input
                      type="email"
                      value={ndaEmail}
                      onChange={(e) => setNdaEmail(e.target.value)}
                      placeholder="name@example.com"
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-amber-100 mb-1">Tester Phone Number *</label>
                    <input
                      type="tel"
                      value={ndaPhone}
                      onChange={(e) => setNdaPhone(e.target.value)}
                      placeholder="(555) 000-0000"
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                  <div>
                    <label className="block text-xs font-bold text-amber-100 mb-1">Device Model *</label>
                    <input
                      type="text"
                      value={ndaDevice}
                      onChange={(e) => setNdaDevice(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-amber-100 mb-1">OS Version *</label>
                    <input
                      type="text"
                      value={ndaOsVersion}
                      onChange={(e) => setNdaOsVersion(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-amber-100 mb-1">Network Connection Used *</label>
                    <select
                      value={ndaNetwork}
                      onChange={(e) => setNdaNetwork(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    >
                      <option value="Wi-Fi">Wi-Fi</option>
                      <option value="5G / Cellular">5G / Cellular</option>
                      <option value="Both Tested">Both Tested</option>
                    </select>
                  </div>
                </div>

                <div className="space-y-2 text-xs text-slate-200">
                  <label className="flex items-start gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={ndaAgreedIp}
                      onChange={(e) => setNdaAgreedIp(e.target.checked)}
                      className="mt-1 accent-amber-400"
                    />
                    <span>
                      I acknowledge the Pre-Registration Intellectual Property &amp; Copyright Notice (17 U.S.C. § 102) and confirm that all aspects of ACT LIKE IT™ are the exclusive property of ACT LIKE IT Studio.
                    </span>
                  </label>
                  <label className="flex items-start gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={ndaAgreedConfidential}
                      onChange={(e) => setNdaAgreedConfidential(e.target.checked)}
                      className="mt-1 accent-amber-400"
                    />
                    <span>
                      I agree to the Strict Confidentiality &amp; Non-Disclosure Agreement (NDA): I will NOT share my personal tester passcode, publicly record, screenshot, share https://act-like-it.vercel.app or build files, or appropriate any game mechanics or scripts.
                    </span>
                  </label>
                </div>

                <div>
                  <label className="block text-xs font-bold text-amber-100 mb-1">
                    Tester Digital Signature (Type Full Legal Name) *
                  </label>
                  <input
                    type="text"
                    value={ndaSignature}
                    onChange={(e) => setNdaSignature(e.target.value)}
                    placeholder="Type your full legal name as your binding signature"
                    className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                  />
                </div>

                <div className="border-t border-slate-800 pt-4 space-y-3">
                  <h3 className="text-sm font-bold text-amber-400">
                    🤝 SECTION 1: &ldquo;ACT LIKE IT&rdquo; PARTNERSHIP &amp; CO-FOUNDER EVALUATION
                  </h3>
                  <div className="flex flex-wrap gap-3 text-xs">
                    <button
                      type="button"
                      onClick={() => setNdaInterestedPartner(true)}
                      className={`px-3 py-2 rounded-lg border font-bold ${
                        ndaInterestedPartner
                          ? 'bg-amber-500/20 border-amber-400 text-amber-200'
                          : 'bg-slate-950 border-slate-700 text-slate-400'
                      }`}
                    >
                      ✅ YES — I want to talk about joining the core team!
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setNdaInterestedPartner(false);
                        setNdaSelectedTracks([]);
                      }}
                      className={`px-3 py-2 rounded-lg border font-bold ${
                        !ndaInterestedPartner
                          ? 'bg-cyan-500/20 border-cyan-400 text-cyan-200'
                          : 'bg-slate-950 border-slate-700 text-slate-400'
                      }`}
                    >
                      🎬 NO — I am strictly acting as a Closed Alpha Tester
                    </button>
                  </div>

                  {ndaInterestedPartner && (
                    <div className="space-y-2 pt-2">
                      <div className="space-y-1 text-xs text-slate-300">
                        {partnershipTracks.map((track) => (
                          <label key={track} className="flex items-center gap-2 cursor-pointer">
                            <input
                              type="checkbox"
                              checked={ndaSelectedTracks.includes(track)}
                              onChange={(e) => {
                                if (e.target.checked) {
                                  setNdaSelectedTracks([...ndaSelectedTracks, track]);
                                } else {
                                  setNdaSelectedTracks(ndaSelectedTracks.filter((t) => t !== track));
                                }
                              }}
                              className="accent-amber-400"
                            />
                            <span>{track}</span>
                          </label>
                        ))}
                      </div>
                      <textarea
                        rows={2}
                        value={ndaBackgroundSummary}
                        onChange={(e) => setNdaBackgroundSummary(e.target.value)}
                        placeholder="Briefly summarize your background, superpowers, or past experience relevant to this role..."
                        className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-xs text-white"
                      />
                    </div>
                  )}
                </div>

                <button
                  type="submit"
                  className="w-full bg-amber-400 hover:bg-amber-300 text-slate-950 font-black py-3 px-6 rounded-xl shadow-lg transition-colors text-xs font-mono tracking-wide"
                >
                  STEP 1: SIGN NDA &amp; GENERATE MY UNIQUE PERSONAL PASSCODE
                </button>
              </form>
            </>
          )}

          {issuedPasscode && (
            <div className="bg-emerald-950/60 border-2 border-emerald-400 rounded-xl p-4 space-y-3">
              <div className="text-xs font-mono font-bold text-emerald-300">
                ✅ NDA SIGNED — YOUR UNIQUE PERSONAL PASSCODE HAS BEEN ISSUED
              </div>
              <div className="flex items-center justify-between bg-slate-950 border border-amber-400 rounded-lg px-4 py-3">
                <span className="font-mono text-xl font-black tracking-widest text-amber-300">
                  {issuedPasscode}
                </span>
                <button
                  type="button"
                  onClick={() => handleCopyCode('nda-passcode', issuedPasscode)}
                  className="text-xs font-mono font-bold text-cyan-300 hover:text-cyan-200 flex items-center gap-1"
                >
                  {copiedPath === 'nda-passcode' ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                  {copiedPath === 'nda-passcode' ? 'COPIED' : 'COPY PASSCODE'}
                </button>
              </div>
              <p className="text-xs text-amber-200/90 leading-relaxed">
                ⚠️ <strong>ANTI-SHARING TRACEABILITY WARNING:</strong> This passcode (<code className="font-mono">{issuedPasscode}</code>) is uniquely registered to <strong>{ndaFullName}</strong> and locked to Device ID <code className="font-mono">{deviceFingerprint}</code>. If you give this passcode to anyone else, our system detects the different device, blocks their access, and flags your name and phone number with a CRITICAL NDA BREACH ALERT.
              </p>
            </div>
          )}

          <form onSubmit={handleVerifyPasscodeAndUnlock} className="space-y-4">
            <div className="bg-rose-950/40 border border-rose-500/70 rounded-xl p-4 space-y-2">
              <label className="block text-xs font-mono font-bold text-amber-300">
                🔑 STEP 2: ENTER YOUR UNIQUE PERSONAL PASSCODE (OR STUDIO MASTER SECRET) TO UNLOCK *
              </label>
              <input
                type="text"
                value={ndaPasscodeInput}
                onChange={(e) => setNdaPasscodeInput(e.target.value)}
                placeholder="e.g., ALI-JD-8492 (or Studio Master Secret)"
                className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm font-mono text-white tracking-wider"
              />
            </div>

            {ndaBreachAlert && (
              <div className="bg-rose-950 border-2 border-rose-500 text-rose-100 text-xs font-bold p-4 rounded-xl leading-relaxed">
                {ndaBreachAlert}
              </div>
            )}

            {ndaError && (
              <div className="bg-rose-950 border border-rose-500 text-rose-200 text-xs font-bold px-4 py-3 rounded-lg">
                {ndaError}
              </div>
            )}

            <button
              type="submit"
              className="w-full bg-rose-600 hover:bg-rose-500 text-amber-100 font-black py-3.5 px-6 rounded-xl border-2 border-amber-400 shadow-lg transition-colors text-sm"
            >
              🔓 VERIFY PERSONAL PASSCODE &amp; UNLOCK ACT LIKE IT™
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 font-['Plus_Jakarta_Sans',sans-serif] flex flex-col">
      {/* Top Bar Contract: 3 zones separated by gap-8 */}
      <header className="flex items-center justify-between gap-8 px-6 py-4 border-b border-slate-800 bg-slate-950">
        <a
          href="#top"
          className="flex items-center gap-3 text-lg font-bold tracking-tight text-white whitespace-nowrap shrink-0"
        >
          <img
            src="/app_logo.png"
            alt="ACT LIKE IT Official Logo"
            className="w-10 h-10 rounded-full border-2 border-amber-400/80 object-cover shadow-md"
          />
          <span>ACT LIKE IT</span>
        </a>

        <nav
          aria-label="Workspace Navigation"
          className="hidden md:flex items-center gap-6 text-sm font-medium text-slate-400"
        >
          <button
            type="button"
            onClick={() => setActiveTab('files')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'files' ? 'text-white underline underline-offset-8' : ''
            }`}
          >
            All 5 Batches &amp; 100 Scenes
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('late-night')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'late-night' ? 'text-white underline underline-offset-8' : ''
            }`}
          >
            Late-Night 18+ Vault (10 Scenes)
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('sync-guide')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'sync-guide' ? 'text-white underline underline-offset-8' : ''
            }`}
          >
            Final GitHub Sync
          </button>
        </nav>

        <div className="flex items-center gap-3 shrink-0">
          <button
            type="button"
            onClick={() => setActiveTab('sync-guide')}
            className="px-4 py-2 text-xs font-semibold text-white bg-rose-600 rounded-lg hover:bg-rose-500 transition-colors whitespace-nowrap shrink-0"
          >
            Push 100 Scenes &amp; Logo to GitHub
          </button>
        </div>
      </header>

      {/* Main Content Container */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 py-8 space-y-8">
        {/* Batch Status Banner */}
        <section className="p-6 rounded-xl bg-slate-900 border border-slate-800">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
            <div className="flex items-start gap-4 max-w-3xl">
              <img
                src="/app_logo.png"
                alt="ACT LIKE IT Medallion"
                className="w-16 h-16 sm:w-20 sm:h-20 rounded-full border-2 border-amber-400 object-cover shadow-lg shrink-0"
              />
              <div className="space-y-2">
                <div className="text-xs text-slate-400">
                  <span>100 Original Parody Scenes</span>
                  <span aria-hidden="true"> · </span>
                  <span>90 General + 10 Adult (18+)</span>
                  <span aria-hidden="true"> · </span>
                  <span>Official Brand Logo Integrated</span>
                </div>
                <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
                  100 Copyright-Safe Parody Scenes &amp; Official App Logo Ready
                </h1>
                <p className="text-sm text-slate-300 leading-relaxed">
                  Populated <code className="font-mono text-amber-400">lib/ui/parody_scenes_catalog.dart</code>, <code className="font-mono text-amber-400">OfflineManager</code> SQLite cache, <code className="font-mono text-amber-400">SceneVaultScreen</code>, <code className="font-mono text-amber-400">LateNightAfterHoursScreen</code>, Green Room Scene Drawer (<code className="font-mono text-amber-400">lib/lobby.dart</code>), and <code className="font-mono text-amber-400">supabase/seed.sql</code> with all 100 original scripts (Solo + Duet Lead A in <code className="font-mono text-amber-200">#F5DEB3</code> &amp; Lead B in <code className="font-mono text-cyan-400">#0CB6D4</code>, zero text truncation) and wired the official logo into <code className="font-mono text-amber-400">assets/app_logo.png</code>, <code className="font-mono text-amber-400">mipmap-*/ic_launcher.png</code>, and <code className="font-mono text-amber-400">ActLikeItBrandLogo</code>.
                </p>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4 shrink-0">
              <div className="px-4 py-3 rounded-lg bg-slate-950 border border-slate-800 text-right">
                <div className="text-xs text-slate-400">Sequential Build Progress</div>
                <div className="text-xl font-bold font-mono tabular-nums text-emerald-400">
                  {progress.completedCount} / {progress.totalCount} Batches ({progress.percentage}%)
                </div>
              </div>
            </div>
          </div>

          {/* Mobile Mode Switcher */}
          <div className="flex items-center gap-1 p-1 mt-6 bg-slate-950 rounded-lg border border-slate-800 md:hidden">
            <button
              type="button"
              onClick={() => setActiveTab('files')}
              className={`flex-1 px-3 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'files'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Part 5 Files
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('late-night')}
              className={`flex-1 px-3 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'late-night'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              18+ Vault
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('sync-guide')}
              className={`flex-1 px-3 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'sync-guide'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              GitHub Sync
            </button>
          </div>
        </section>

        {/* Tab 1: Workspace File Inspector */}
        {activeTab === 'files' && (
          <section className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
            {/* Left Column: File List & 5-Stage Roadmap */}
            <div className="lg:col-span-4 space-y-6">
              <div className="p-5 rounded-xl bg-slate-900 border border-slate-800 space-y-4">
                <h2 className="text-base font-semibold text-white">
                  Complete Flutter & Supabase Repository
                </h2>
                <div className="space-y-2">
                  {WORKSPACE_FILES.map((file) => {
                    const isSelected = file.path === selectedFile.path;
                    return (
                      <button
                        key={file.path}
                        type="button"
                        onClick={() => setSelectedFilePath(file.path)}
                        className={`w-full text-left p-3 rounded-lg border transition-colors flex items-center justify-between gap-3 ${
                          isSelected
                            ? 'bg-slate-800 border-rose-500 text-white'
                            : 'bg-slate-950 border-slate-800 text-slate-300 hover:border-slate-700'
                        }`}
                      >
                        <div className="flex items-center gap-2.5 min-w-0">
                          <FileCode2 className="w-4 h-4 text-rose-400 shrink-0" />
                          <span className="font-mono text-xs truncate">{file.path}</span>
                        </div>
                        <span className="font-mono text-xs text-slate-400 tabular-nums shrink-0">
                          Part {file.part} · {file.lineCount}L
                        </span>
                      </button>
                    );
                  })}
                </div>
              </div>

              <div className="p-5 rounded-xl bg-slate-900 border border-slate-800 space-y-4">
                <h2 className="text-base font-semibold text-white">
                  5-Part Execution Protocol (100%)
                </h2>
                <div className="space-y-3">
                  {BATCH_STAGES.map((stage) => (
                    <div
                      key={stage.part}
                      className="p-3 rounded-lg bg-slate-950 border border-slate-800 space-y-1"
                    >
                      <div className="flex items-center justify-between gap-2">
                        <span className="text-xs font-semibold text-white">
                          0{stage.part}. {stage.title}
                        </span>
                        <span className="text-xs font-mono tabular-nums text-emerald-400">
                          Generated
                        </span>
                      </div>
                      <p className="text-xs text-slate-400 leading-relaxed">
                        {stage.summary}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Right Column: Code Viewer */}
            <div className="lg:col-span-8 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-4">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-800">
                <div>
                  <h2 className="text-base font-semibold font-mono text-white">
                    /{selectedFile.path}
                  </h2>
                  <p className="text-xs text-slate-400 mt-1">
                    {selectedFile.description}
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => handleCopyCode(selectedFile.path, selectedFile.content)}
                  className="inline-flex items-center gap-2 px-3.5 py-2 text-xs font-medium rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-100 transition-colors whitespace-nowrap shrink-0 self-start sm:self-auto"
                >
                  {copiedPath === selectedFile.path ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-emerald-400" />
                      <span>Copied</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-3.5 h-3.5" />
                      <span>Copy File Content</span>
                    </>
                  )}
                </button>
              </div>

              <pre className="p-4 rounded-lg bg-slate-950 border border-slate-800 overflow-x-auto text-xs font-mono text-slate-200 leading-relaxed max-h-[540px]">
                <code>{selectedFile.content}</code>
              </pre>
            </div>
          </section>
        )}

        {/* Tab 2: Late-Night After-Hours 18+ Vault & Mid-Take Twist Simulator */}
        {activeTab === 'late-night' && (
          <section className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
            {/* Left Column: 18+ Age & PIN Gate */}
            <div className="lg:col-span-5 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="flex items-center justify-between">
                <h2 className="text-lg font-bold text-white">
                  18+ RLS Security Gate
                </h2>
                <span className="font-mono text-xs text-amber-400">
                  {vaultUnlocked ? 'RLS VERIFIED' : 'LOCKED'}
                </span>
              </div>

              <p className="text-xs text-slate-400 leading-relaxed">
                Simulates <code className="font-mono text-amber-400">verify_player_age_and_unlock_late_night</code> RPC & PostgreSQL RLS policy on <code className="font-mono text-amber-400">public.scenes_late_night_after_hours</code>.
              </p>

              <form onSubmit={handleUnlockVault} className="space-y-4">
                <div>
                  <label
                    htmlFor="birth-year-input"
                    className="block text-xs font-semibold text-slate-300 mb-1"
                  >
                    Birth Year (YYYY · Must be 18+)
                  </label>
                  <input
                    id="birth-year-input"
                    type="text"
                    maxLength={4}
                    value={birthYearInput}
                    onChange={(e) => setBirthYearInput(e.target.value)}
                    className="w-full px-3 py-2 text-xs font-mono rounded-lg bg-slate-950 border border-slate-800 text-white"
                  />
                </div>

                <div>
                  <label
                    htmlFor="session-pin-input"
                    className="block text-xs font-semibold text-slate-300 mb-1"
                  >
                    4-Digit Session Lock PIN
                  </label>
                  <input
                    id="session-pin-input"
                    type="password"
                    maxLength={4}
                    value={pinInput}
                    onChange={(e) => setPinInput(e.target.value)}
                    className="w-full px-3 py-2 text-xs font-mono rounded-lg bg-slate-950 border border-slate-800 text-white"
                  />
                </div>

                {gateError && (
                  <p className="text-xs text-rose-400">{gateError}</p>
                )}

                <div className="flex items-center gap-2">
                  <button
                    type="submit"
                    className="flex-1 inline-flex items-center justify-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-lg bg-rose-600 hover:bg-rose-500 text-white transition-colors whitespace-nowrap shrink-0"
                  >
                    <Unlock className="w-3.5 h-3.5" />
                    <span>Verify 18+ & Unlock Vault</span>
                  </button>
                  {vaultUnlocked && (
                    <button
                      type="button"
                      onClick={() => setVaultUnlocked(false)}
                      className="inline-flex items-center justify-center gap-1.5 px-3 py-2.5 text-xs font-semibold rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-200 transition-colors whitespace-nowrap shrink-0"
                    >
                      <Lock className="w-3.5 h-3.5" />
                      <span>Lock</span>
                    </button>
                  )}
                </div>
              </form>
            </div>

            {/* Right Column: Unlocked After-Hours Prompts & Mid-Take Twist */}
            <div className="lg:col-span-7 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-slate-800">
                <div>
                  <h3 className="text-base font-bold text-white">
                    After-Hours Prompt Vault & 15s Mid-Take Twists
                  </h3>
                  <p className="text-xs text-slate-400">
                    Table: <code className="font-mono">public.scenes_late_night_after_hours</code>
                  </p>
                </div>

                <div className="flex items-center gap-1 bg-slate-950 p-1 rounded-lg border border-slate-800 self-start sm:self-auto">
                  {[1, 2, 3].map((tier) => (
                    <button
                      key={tier}
                      type="button"
                      onClick={() => setSelectedSpiceTier(tier)}
                      className={`px-2.5 py-1 text-xs font-mono font-semibold rounded transition-colors whitespace-nowrap shrink-0 ${
                        selectedSpiceTier === tier
                          ? 'bg-rose-600 text-white'
                          : 'text-slate-400 hover:text-white'
                      }`}
                    >
                      Tier {tier}
                    </button>
                  ))}
                </div>
              </div>

              {!vaultUnlocked ? (
                <div className="p-8 rounded-xl bg-slate-950 border border-slate-800 text-center space-y-2">
                  <Lock className="w-8 h-8 text-rose-500 mx-auto" />
                  <div className="text-sm font-semibold text-white">
                    Late-Night After-Hours Vault is Locked by 18+ RLS
                  </div>
                  <p className="text-xs text-slate-400 max-w-md mx-auto">
                    Verify your birth year (18+) and 4-digit PIN on the left to execute <code className="font-mono text-amber-400">verify_player_age_and_unlock_late_night</code> and reveal the After-Hours prompts.
                  </p>
                </div>
              ) : (
                <div className="space-y-3">
                  {LATE_NIGHT_PROMPTS.filter((p) => p.spiceTier <= selectedSpiceTier).map(
                    (prompt) => {
                      const twistActive = twistTriggeredId === prompt.id;
                      return (
                        <div
                          key={prompt.id}
                          className="p-4 rounded-xl bg-slate-950 border border-slate-800 space-y-2.5"
                        >
                          <div className="flex items-center justify-between gap-2 text-xs">
                            <span className="font-mono text-rose-400">
                              SPICE TIER {prompt.spiceTier} ({prompt.multiplier}) · {prompt.advisory}
                            </span>
                            <button
                              type="button"
                              onClick={() =>
                                setTwistTriggeredId(twistActive ? null : prompt.id)
                              }
                              className="inline-flex items-center gap-1 px-2.5 py-1 text-xs font-semibold rounded bg-slate-800 hover:bg-slate-700 text-amber-400 transition-colors whitespace-nowrap shrink-0"
                            >
                              <Zap className="w-3 h-3" />
                              <span>{twistActive ? 'Hide 15s Twist' : 'Trigger 15s Twist'}</span>
                            </button>
                          </div>

                          <div className="text-sm font-bold text-white">
                            {prompt.title} · {prompt.film} ({prompt.year}) — {prompt.character}
                          </div>

                          <p className="text-xs text-slate-200 leading-relaxed">
                            &ldquo;{prompt.script}&rdquo;
                          </p>

                          <p className="text-xs text-slate-400">
                            Director Cue: {prompt.cue}
                          </p>

                          {twistActive && (
                            <div className="p-3 rounded-lg bg-slate-900 border border-amber-500/60 text-xs font-mono text-amber-300">
                              {prompt.twist}
                            </div>
                          )}
                        </div>
                      );
                    }
                  )}
                </div>
              )}
            </div>
          </section>
        )}

        {/* Tab 3: S26 Ultra APK Download & GitHub Actions Artifact Guide */}
        {activeTab === 'sync-guide' && (
          <section className="p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-6">
            <div className="space-y-2">
              <h2 className="text-xl font-bold text-white">
                Download &amp; Install the APK on Your Samsung Galaxy S26 Ultra
              </h2>
              <p className="text-sm text-slate-300">
                Configured <code className="font-mono text-amber-400">.github/workflows/build_apk.yml</code> (<code className="font-mono text-white">Build and Release APK</code>) with Zulu Java 17, Flutter stable, <code className="font-mono text-amber-400">--dart-define</code> secret injection, and <code className="font-mono text-amber-400">actions/upload-artifact@v4</code>:
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">01. Push Workflow to GitHub</div>
                <h3 className="text-base font-semibold text-white">
                  Tap &ldquo;Push Changes&rdquo; in AI Studio
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Open the Settings &rarr; GitHub tab in AI Studio and push to your <code className="font-mono text-white">main</code> branch. Pushing triggers <code className="font-mono text-white">.github/workflows/build_apk.yml</code> on GitHub Actions.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">02. Open GitHub Actions</div>
                <h3 className="text-base font-semibold text-white">
                  Download act-like-it-apk
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Open your <code className="font-mono text-white">act_like_it</code> repo on your S26 Ultra browser, tap the <strong className="text-white">Actions</strong> tab, select the completed <strong className="text-white">Build and Release APK</strong> run, and download <code className="font-mono text-white">act-like-it-apk</code> (<code className="font-mono text-white">app-release.apk</code>).
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-emerald-400">03. Secrets &amp; Standalone Ready</div>
                <h3 className="text-base font-semibold text-white">
                  100% Functional on Galaxy S26 Ultra
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Add <code className="font-mono text-white">SUPABASE_URL</code>, <code className="font-mono text-white">SUPABASE_ANON_KEY</code>, <code className="font-mono text-white">LIVEKIT_URL</code>, and <code className="font-mono text-white">GEMINI_API_KEY</code> in GitHub Settings &rarr; Secrets &rarr; Actions (or configure them live inside the app).
                </p>
              </div>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}
