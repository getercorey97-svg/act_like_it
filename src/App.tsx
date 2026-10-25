import React, { useState } from 'react';
import {
  Copy,
  Check,
  FileCode2,
  Lock,
  Unlock,
  Zap,
  RefreshCw,
  ShieldCheck,
  Rocket,
  Search,
  Eye,
  EyeOff,
} from 'lucide-react';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  getBatchCompletionRatio,
  verifyLateNightAgeGate,
} from './utils/part1Specs';
import {
  FOUNDER_CONTACT_EMAIL,
  NdaApprovalStatus,
  NdaTesterDossierRecord,
  createPendingTesterDossier,
  evaluatePasscodeUnlockAttempt,
  getTesterVisiblePasscode,
  updateTesterApprovalStatus,
  verifyFounderAdminCredentials,
} from './utils/ndaApprovalLogic';

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

function loadRegistryFromStorage(): Record<string, NdaTesterDossierRecord> {
  try {
    const raw =
      localStorage.getItem('act_like_it_nda_passcode_registry_v2') ?? '{}';
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === 'object') {
      return parsed as Record<string, NdaTesterDossierRecord>;
    }
  } catch {
    // ignore storage errors
  }
  return {};
}

function saveRegistryToStorage(
  registry: Record<string, NdaTesterDossierRecord>
): void {
  try {
    localStorage.setItem(
      'act_like_it_nda_passcode_registry_v2',
      JSON.stringify(registry)
    );
  } catch {
    // ignore storage errors
  }
}

export default function App() {
  const [deviceFingerprint] = useState<string>(() => {
    try {
      const existing = localStorage.getItem(
        'act_like_it_device_fingerprint_v1'
      );
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
      return (
        localStorage.getItem('act_like_it_nda_gate_unlocked_v2') === 'true'
      );
    } catch {
      return false;
    }
  });

  const [ndaMode, setNdaMode] = useState<'sign' | 'unlock' | 'admin'>('sign');
  const [ndaFullName, setNdaFullName] = useState<string>('');
  const [ndaEmail, setNdaEmail] = useState<string>('');
  const [ndaPhone, setNdaPhone] = useState<string>('');
  const [ndaDevice, setNdaDevice] = useState<string>(
    'iPhone 16 Pro Max / Galaxy S26 Ultra'
  );
  const [ndaOsVersion, setNdaOsVersion] = useState<string>(
    'iOS 18 / Android 16'
  );
  const [ndaNetwork, setNdaNetwork] = useState<string>('Both Tested');
  const [ndaSignature, setNdaSignature] = useState<string>('');
  const [ndaAgreedIp, setNdaAgreedIp] = useState<boolean>(false);
  const [ndaAgreedConfidential, setNdaAgreedConfidential] =
    useState<boolean>(false);
  const [ndaInterestedPartner, setNdaInterestedPartner] =
    useState<boolean>(false);
  const [ndaSelectedTracks, setNdaSelectedTracks] = useState<string[]>([]);
  const [ndaBackgroundSummary, setNdaBackgroundSummary] = useState<string>('');

  // Current device's signed NDA dossier (status starts as 'pending' — passcode hidden until 'approved')
  const [currentTesterDossier, setCurrentTesterDossier] =
    useState<NdaTesterDossierRecord | null>(() => {
      const reg = loadRegistryFromStorage();
      const found = Object.values(reg).find(
        (r) => r.bound_device_fingerprint === deviceFingerprint
      );
      return found ?? null;
    });
  const [statusCheckMessage, setStatusCheckMessage] = useState<string | null>(
    null
  );

  // Dedicated Founder's Admin Login (`admin88` / `Cg0167853!8808`) & Command Center state
  const [adminUnlocked, setAdminUnlocked] = useState<boolean>(false);
  const [adminUsernameInput, setAdminUsernameInput] = useState<string>('');
  const [adminPasswordInput, setAdminPasswordInput] = useState<string>('');
  const [showAdminPassword, setShowAdminPassword] = useState<boolean>(false);
  const [adminFilter, setAdminFilter] = useState<
    'all' | 'pending' | 'approved' | 'partner' | 'rejected'
  >('all');
  const [adminSearchQuery, setAdminSearchQuery] = useState<string>('');
  const [adminError, setAdminError] = useState<string | null>(null);
  const [registryState, setRegistryState] = useState<
    Record<string, NdaTesterDossierRecord>
  >(() => loadRegistryFromStorage());

  const [ndaPasscodeInput, setNdaPasscodeInput] = useState<string>('');
  const [ndaError, setNdaError] = useState<string | null>(null);
  const [ndaBreachAlert, setNdaBreachAlert] = useState<string | null>(null);

  const [selectedFilePath, setSelectedFilePath] = useState<string>(
    'lib/auth/nda_tester_gate.dart'
  );
  const [copiedPath, setCopiedPath] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<
    'files' | 'late-night' | 'sync-guide'
  >('files');

  // Part 5 Late-Night 18+ Gate Simulator State
  const [birthYearInput, setBirthYearInput] = useState<string>('1997');
  const [pinInput, setPinInput] = useState<string>('2026');
  const [vaultUnlocked, setVaultUnlocked] = useState<boolean>(false);
  const [gateError, setGateError] = useState<string | null>(null);
  const [selectedSpiceTier, setSelectedSpiceTier] = useState<number>(3);
  const [twistTriggeredId, setTwistTriggeredId] = useState<string | null>(
    'ln-1'
  );

  const selectedFile =
    WORKSPACE_FILES.find((f) => f.path === selectedFilePath) ??
    WORKSPACE_FILES[0];
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

  const handleSignNdaAndSubmitForApproval = (e: React.FormEvent) => {
    e.preventDefault();
    setNdaError(null);
    setNdaBreachAlert(null);
    setStatusCheckMessage(null);

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
      setNdaError(
        'You must check BOTH Legal & Non-Disclosure (NDA) acknowledgment boxes in Section 0.'
      );
      return;
    }
    if (ndaSignature.trim().length < 3) {
      setNdaError(
        'Please type your Full Legal Name in the Tester Digital Signature box.'
      );
      return;
    }

    const pendingRecord = createPendingTesterDossier({
      fullName: ndaFullName,
      email: ndaEmail,
      phone: ndaPhone,
      signature: ndaSignature,
      deviceFingerprint,
      deviceModel: ndaDevice,
      osVersion: ndaOsVersion,
      networkConnection: ndaNetwork,
      agreedIp: ndaAgreedIp,
      agreedConfidential: ndaAgreedConfidential,
      interestedInPartnership: ndaInterestedPartner,
      selectedTracks: ndaSelectedTracks,
      backgroundSummary: ndaBackgroundSummary,
    });

    const latestRegistry = loadRegistryFromStorage();
    const nextRegistry = {
      ...latestRegistry,
      [pendingRecord.unique_passcode.toUpperCase()]: pendingRecord,
    };
    saveRegistryToStorage(nextRegistry);
    setRegistryState(nextRegistry);
    setCurrentTesterDossier(pendingRecord);
    setStatusCheckMessage(
      `NDA submitted! Your dossier is now in Founder Corey Geter's approval queue (${FOUNDER_CONTACT_EMAIL}).`
    );
  };

  const handleCheckApprovalStatus = () => {
    setNdaError(null);
    const latestRegistry = loadRegistryFromStorage();
    setRegistryState(latestRegistry);

    if (!currentTesterDossier) return;
    const code = currentTesterDossier.unique_passcode.toUpperCase();
    const refreshed = latestRegistry[code] ?? currentTesterDossier;
    setCurrentTesterDossier(refreshed);

    if (refreshed.approval_status === 'approved') {
      setNdaPasscodeInput(refreshed.unique_passcode);
      setStatusCheckMessage(
        `🎉 APPROVED BY FOUNDER! Your Unique Personal Passcode (${refreshed.unique_passcode}) is now unlocked below.`
      );
    } else if (refreshed.approval_status === 'rejected') {
      setStatusCheckMessage(
        `🚫 Access request was declined by Studio Administration (${FOUNDER_CONTACT_EMAIL}).`
      );
    } else {
      setStatusCheckMessage(
        `⏳ Status is still PENDING FOUNDER APPROVAL. Contact ${FOUNDER_CONTACT_EMAIL} if you need expedited clearance.`
      );
    }
  };

  const handleFounderAdminLogin = (e: React.FormEvent) => {
    e.preventDefault();
    const envUser = import.meta.env.VITE_FOUNDER_ADMIN_USER ?? '';
    const envPass = import.meta.env.VITE_FOUNDER_ADMIN_PASSWORD ?? '';
    if (
      !verifyFounderAdminCredentials(
        adminUsernameInput,
        adminPasswordInput,
        envUser,
        envPass
      )
    ) {
      setAdminError(
        'ACCESS DENIED: Invalid Founder Admin Username or Password. This portal is restricted exclusively to Founder Corey Geter.'
      );
      return;
    }
    setAdminError(null);
    setAdminUnlocked(true);
    setRegistryState(loadRegistryFromStorage());
  };

  const handleFounderLaunchMainApp = () => {
    try {
      localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
    } catch {
      // ignore
    }
    setNdaUnlocked(true);
  };

  const handleFounderSetApprovalStatus = (
    passcode: string,
    newStatus: NdaApprovalStatus
  ) => {
    const latestRegistry = loadRegistryFromStorage();
    const updated = updateTesterApprovalStatus(
      latestRegistry,
      passcode,
      newStatus,
      'Founder (Corey Geter · admin88)'
    );
    saveRegistryToStorage(updated);
    setRegistryState(updated);

    const key = passcode.toUpperCase();
    if (
      currentTesterDossier &&
      currentTesterDossier.unique_passcode.toUpperCase() === key &&
      updated[key]
    ) {
      setCurrentTesterDossier(updated[key]);
      if (newStatus === 'approved') {
        setNdaPasscodeInput(updated[key].unique_passcode);
      }
    }
  };

  const handleVerifyPasscodeAndUnlock = (e: React.FormEvent) => {
    e.preventDefault();
    setNdaError(null);
    setNdaBreachAlert(null);

    const latestRegistry = loadRegistryFromStorage();
    setRegistryState(latestRegistry);

    const outcome = evaluatePasscodeUnlockAttempt({
      enteredCode: ndaPasscodeInput,
      currentDeviceFingerprint: deviceFingerprint,
      registry: latestRegistry,
      envSecretOverride: import.meta.env.VITE_ADMIN_PASSCODE ?? '',
    });

    if (outcome.status === 'unlocked_master') {
      try {
        localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
      } catch {
        // ignore
      }
      setNdaUnlocked(true);
      return;
    }

    if (outcome.status === 'unlocked_tester') {
      try {
        localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
        localStorage.setItem(
          'act_like_it_nda_dossier_payload_v2',
          JSON.stringify(outcome.record)
        );
      } catch {
        // ignore
      }
      setNdaUnlocked(true);
      return;
    }

    if (outcome.status === 'breach_detected') {
      setNdaBreachAlert(outcome.breachAlertMessage);
      return;
    }

    setNdaError(outcome.errorMessage);
  };

  const visibleApprovedPasscode = getTesterVisiblePasscode(
    currentTesterDossier
  );

  if (!ndaUnlocked) {
    const partnershipTracks = [
      '1. Co-Founder & Chief Operating Officer (COO) / Studio Head',
      '2. Chief Technology Officer (CTO) / Lead Multiplayer Systems Engineer',
      '3. Head of Growth, Marketing & Viral Acquisition',
      "4. Senior Creative Director & Writer's Room Lead",
      '5. Strategic Angel Investor / Venture Partner',
    ];
    const allQueueRecords = Object.values(registryState);
    const totalCount = allQueueRecords.length;
    const pendingCount = allQueueRecords.filter(
      (r) => (r.approval_status ?? 'pending') === 'pending'
    ).length;
    const approvedCount = allQueueRecords.filter(
      (r) => r.approval_status === 'approved'
    ).length;
    const partnerCount = allQueueRecords.filter(
      (r) => r.interested_in_partnership
    ).length;
    const rejectedCount = allQueueRecords.filter(
      (r) => r.approval_status === 'rejected'
    ).length;

    const searchLower = adminSearchQuery.trim().toLowerCase();
    const filteredAdminRecords = allQueueRecords.filter((rec) => {
      const status = rec.approval_status ?? 'pending';
      if (adminFilter === 'pending' && status !== 'pending') return false;
      if (adminFilter === 'approved' && status !== 'approved') return false;
      if (adminFilter === 'rejected' && status !== 'rejected') return false;
      if (adminFilter === 'partner' && !rec.interested_in_partnership)
        return false;
      if (!searchLower) return true;
      const hay = `${rec.full_legal_name} ${rec.email} ${rec.phone_number} ${rec.unique_passcode} ${rec.bound_device_fingerprint}`.toLowerCase();
      return hay.contains(searchLower);
    });

    return (
      <div className="min-h-screen bg-slate-950 text-slate-100 font-['Plus_Jakarta_Sans',sans-serif] py-8 px-4 flex items-center justify-center">
        <div className="max-w-4xl w-full bg-slate-900 border-2 border-amber-500/80 rounded-2xl p-6 md:p-8 shadow-2xl space-y-6">
          <div className="flex items-center justify-between gap-3 bg-rose-950/80 border border-rose-500 rounded-xl px-4 py-3 text-rose-200 text-xs font-mono font-bold">
            <div className="flex items-center gap-2">
              <Lock className="w-4 h-4 text-rose-400 shrink-0" />
              <span>
                MANDATORY CLOSED ALPHA NDA &amp; FOUNDER APPROVAL LOCK
              </span>
            </div>
            <span className="text-amber-300">
              DEVICE ID: {deviceFingerprint}
            </span>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-2 bg-slate-950 p-1.5 rounded-xl border border-slate-800 text-xs font-mono font-bold">
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
              1. SIGN NDA (REQUEST ACCESS)
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
              2. ENTER APPROVED PASSCODE
            </button>
            <button
              type="button"
              onClick={() => {
                setNdaMode('admin');
                setNdaError(null);
                setRegistryState(loadRegistryFromStorage());
              }}
              className={`py-2.5 px-3 rounded-lg transition-colors ${
                ndaMode === 'admin'
                  ? 'bg-rose-600 text-white'
                  : 'text-rose-300 hover:bg-slate-900'
              }`}
            >
              🛡️ 3. FOUNDER ADMIN LOGIN
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

          {/* TAB 3: DEDICATED FOUNDER'S ADMIN LOGIN PAGE & COMMAND CENTER DASHBOARD */}
          {ndaMode === 'admin' && (
            <div className="bg-slate-950 border-2 border-rose-500/80 rounded-xl p-5 md:p-6 space-y-5">
              {!adminUnlocked ? (
                <form
                  onSubmit={handleFounderAdminLogin}
                  className="space-y-4 max-w-xl mx-auto"
                >
                  <div className="flex items-center gap-3 pb-2 border-b border-slate-800">
                    <div className="p-2.5 rounded-xl bg-rose-950 border border-rose-500 text-amber-300">
                      <ShieldCheck className="w-6 h-6" />
                    </div>
                    <div>
                      <h2 className="text-sm md:text-base font-mono font-black text-amber-300">
                        🛡️ FOUNDER&rsquo;S EXECUTIVE ADMIN LOGIN
                      </h2>
                      <p className="text-xs text-slate-400">
                        Restricted exclusively to Founder Corey Geter (
                        {FOUNDER_CONTACT_EMAIL})
                      </p>
                    </div>
                  </div>

                  <p className="text-xs text-slate-300 leading-relaxed">
                    Sign in with your dedicated Founder Admin Username and
                    Password to open the Executive Command Center, review all
                    pending NDA &amp; Co-Founder Dossiers, approve or reject
                    testers, and launch directly into the main{' '}
                    <strong className="text-amber-300">ACT LIKE IT™</strong>{' '}
                    application.
                  </p>

                  <div>
                    <label
                      htmlFor="founder-admin-username"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Founder Admin Username *
                    </label>
                    <input
                      id="founder-admin-username"
                      type="text"
                      value={adminUsernameInput}
                      onChange={(e) => setAdminUsernameInput(e.target.value)}
                      placeholder="Enter Founder Admin Username"
                      autoComplete="username"
                      className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2.5 text-sm font-mono text-white"
                    />
                  </div>

                  <div>
                    <label
                      htmlFor="founder-admin-password"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Founder Admin Password *
                    </label>
                    <div className="relative">
                      <input
                        id="founder-admin-password"
                        type={showAdminPassword ? 'text' : 'password'}
                        value={adminPasswordInput}
                        onChange={(e) => setAdminPasswordInput(e.target.value)}
                        placeholder="Enter Founder Admin Password"
                        autoComplete="current-password"
                        className="w-full bg-slate-900 border border-slate-700 rounded-lg pl-3 pr-10 py-2.5 text-sm font-mono text-white"
                      />
                      <button
                        type="button"
                        onClick={() => setShowAdminPassword(!showAdminPassword)}
                        aria-label="Toggle password visibility"
                        className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white"
                      >
                        {showAdminPassword ? (
                          <EyeOff className="w-4 h-4" />
                        ) : (
                          <Eye className="w-4 h-4" />
                        )}
                      </button>
                    </div>
                  </div>

                  {adminError && (
                    <div className="bg-rose-950 border border-rose-500 text-rose-200 text-xs font-bold px-3.5 py-2.5 rounded-lg">
                      {adminError}
                    </div>
                  )}

                  <button
                    type="submit"
                    className="w-full bg-amber-400 hover:bg-amber-300 text-slate-950 font-black py-3 px-4 rounded-xl text-xs font-mono tracking-wide shadow-lg transition-colors"
                  >
                    AUTHENTICATE &amp; OPEN FOUNDER COMMAND CENTER
                  </button>
                </form>
              ) : (
                <div className="space-y-5">
                  {/* Executive Command Header + Direct Launch into App */}
                  <div className="p-4 rounded-xl bg-slate-900 border-2 border-amber-400/80 space-y-3">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <div>
                        <h2 className="text-sm md:text-base font-mono font-black text-amber-300">
                          👑 FOUNDER COMMAND CENTER &amp; NDA APPROVAL DASHBOARD
                        </h2>
                        <p className="text-xs text-emerald-400 font-mono font-semibold">
                          Authenticated as Founder Corey Geter (admin88) ·
                          Supabase Sync: public.nda_tester_approvals
                        </p>
                      </div>
                      <button
                        type="button"
                        onClick={() =>
                          setRegistryState(loadRegistryFromStorage())
                        }
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-950 border border-cyan-500/60 text-cyan-300 text-xs font-mono font-bold hover:bg-slate-800"
                      >
                        <RefreshCw className="w-3.5 h-3.5" />
                        <span>REFRESH QUEUE</span>
                      </button>
                    </div>

                    <button
                      type="button"
                      onClick={handleFounderLaunchMainApp}
                      className="w-full bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-mono font-black text-xs py-3 px-4 rounded-xl shadow-lg inline-flex items-center justify-center gap-2 transition-colors"
                    >
                      <Rocket className="w-4 h-4" />
                      <span>
                        LAUNCH INTO ACT LIKE IT™ MAIN APP (FOUNDER BYPASS)
                      </span>
                    </button>
                  </div>

                  {/* KPI Telemetry Strip */}
                  <div className="grid grid-cols-2 sm:grid-cols-5 gap-2.5">
                    <div className="p-3 rounded-xl bg-slate-900 border border-cyan-500/40">
                      <div className="text-[10px] font-mono text-slate-400">
                        TOTAL DOSSIERS
                      </div>
                      <div className="text-lg font-mono font-black text-cyan-300">
                        {totalCount}
                      </div>
                    </div>
                    <div className="p-3 rounded-xl bg-slate-900 border border-amber-500/40">
                      <div className="text-[10px] font-mono text-slate-400">
                        PENDING REVIEW
                      </div>
                      <div className="text-lg font-mono font-black text-amber-300">
                        {pendingCount}
                      </div>
                    </div>
                    <div className="p-3 rounded-xl bg-slate-900 border border-emerald-500/40">
                      <div className="text-[10px] font-mono text-slate-400">
                        APPROVED
                      </div>
                      <div className="text-lg font-mono font-black text-emerald-300">
                        {approvedCount}
                      </div>
                    </div>
                    <div className="p-3 rounded-xl bg-slate-900 border border-purple-500/40">
                      <div className="text-[10px] font-mono text-slate-400">
                        PARTNER TRACK
                      </div>
                      <div className="text-lg font-mono font-black text-purple-300">
                        {partnerCount}
                      </div>
                    </div>
                    <div className="p-3 rounded-xl bg-slate-900 border border-rose-500/40">
                      <div className="text-[10px] font-mono text-slate-400">
                        REJECTED
                      </div>
                      <div className="text-lg font-mono font-black text-rose-300">
                        {rejectedCount}
                      </div>
                    </div>
                  </div>

                  {/* Filter Tabs & Search */}
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2.5">
                    <div className="flex flex-wrap gap-1.5">
                      {(
                        [
                          ['all', `ALL (${totalCount})`],
                          ['pending', `⏳ PENDING (${pendingCount})`],
                          ['approved', `✅ APPROVED (${approvedCount})`],
                          ['partner', `🤝 PARTNER TRACK (${partnerCount})`],
                          ['rejected', `🚫 REJECTED (${rejectedCount})`],
                        ] as const
                      ).map(([key, label]) => (
                        <button
                          key={key}
                          type="button"
                          onClick={() => setAdminFilter(key)}
                          className={`px-2.5 py-1.5 rounded-lg text-[11px] font-mono font-black transition-colors ${
                            adminFilter === key
                              ? 'bg-amber-400 text-slate-950'
                              : 'bg-slate-900 text-slate-300 border border-slate-800 hover:border-slate-700'
                          }`}
                        >
                          {label}
                        </button>
                      ))}
                    </div>

                    <div className="relative min-w-[220px]">
                      <Search className="w-3.5 h-3.5 text-cyan-400 absolute left-3 top-1/2 -translate-y-1/2" />
                      <input
                        type="text"
                        value={adminSearchQuery}
                        onChange={(e) => setAdminSearchQuery(e.target.value)}
                        placeholder="Search name, email, passcode..."
                        className="w-full bg-slate-900 border border-slate-700 rounded-lg pl-8 pr-3 py-1.5 text-xs text-white"
                      />
                    </div>
                  </div>

                  {filteredAdminRecords.length === 0 ? (
                    <div className="p-5 rounded-xl bg-slate-900 border border-slate-800 text-xs text-slate-400 text-center">
                      No tester NDA dossiers match the current filter.
                    </div>
                  ) : (
                    <div className="space-y-3">
                      {filteredAdminRecords.map((rec) => {
                        const status = rec.approval_status ?? 'pending';
                        const badgeClass =
                          status === 'approved'
                            ? 'bg-emerald-950 text-emerald-300 border-emerald-500'
                            : status === 'rejected'
                            ? 'bg-rose-950 text-rose-300 border-rose-500'
                            : 'bg-amber-950 text-amber-300 border-amber-500';

                        return (
                          <div
                            key={rec.unique_passcode}
                            className="p-4 rounded-xl bg-slate-900 border border-slate-700 space-y-2.5"
                          >
                            <div className="flex flex-wrap items-center justify-between gap-2">
                              <div className="text-xs font-bold text-white">
                                {rec.full_legal_name} · {rec.email} ·{' '}
                                {rec.phone_number}
                              </div>
                              <span
                                className={`px-2.5 py-0.5 rounded border text-[11px] font-mono font-black uppercase ${badgeClass}`}
                              >
                                {status}
                              </span>
                            </div>

                            <div className="text-xs font-mono text-amber-200 leading-relaxed">
                              Passcode:{' '}
                              <strong className="text-amber-300">
                                {rec.unique_passcode}
                              </strong>{' '}
                              · Bound Device: {rec.bound_device_fingerprint}
                              <br />
                              Device: {rec.device_model} ({rec.os_version}) ·
                              Network: {rec.network_connection_used} · Signature:{' '}
                              &ldquo;{rec.digital_signature}&rdquo;
                            </div>

                            {rec.interested_in_partnership && (
                              <div className="p-2.5 rounded-lg bg-amber-950/40 border border-amber-500/60 text-xs text-amber-200">
                                <strong>🤝 CO-FOUNDER / PARTNER TRACK:</strong>{' '}
                                {rec.selected_partnership_tracks.join(', ')}
                                {rec.partnership_background_summary && (
                                  <div className="text-slate-300 mt-1">
                                    Summary: {rec.partnership_background_summary}
                                  </div>
                                )}
                              </div>
                            )}

                            <div className="flex flex-wrap items-center gap-2 pt-1">
                              <button
                                type="button"
                                onClick={() =>
                                  handleFounderSetApprovalStatus(
                                    rec.unique_passcode,
                                    'approved'
                                  )
                                }
                                className="px-3 py-1.5 rounded-lg bg-emerald-500 hover:bg-emerald-400 text-slate-950 text-xs font-mono font-black"
                              >
                                ✅ APPROVE &amp; ISSUE PASSCODE
                              </button>
                              <button
                                type="button"
                                onClick={() =>
                                  handleFounderSetApprovalStatus(
                                    rec.unique_passcode,
                                    'rejected'
                                  )
                                }
                                className="px-3 py-1.5 rounded-lg bg-rose-950 hover:bg-rose-900 border border-rose-500 text-rose-200 text-xs font-mono font-bold"
                              >
                                🚫 REJECT
                              </button>
                              <button
                                type="button"
                                onClick={() =>
                                  handleCopyCode(
                                    `admin-${rec.unique_passcode}`,
                                    rec.unique_passcode
                                  )
                                }
                                className="px-3 py-1.5 rounded-lg bg-slate-950 hover:bg-slate-800 border border-cyan-500/60 text-cyan-300 text-xs font-mono font-bold inline-flex items-center gap-1"
                              >
                                {copiedPath ===
                                `admin-${rec.unique_passcode}` ? (
                                  <Check className="w-3.5 h-3.5" />
                                ) : (
                                  <Copy className="w-3.5 h-3.5" />
                                )}
                                <span>
                                  {copiedPath ===
                                  `admin-${rec.unique_passcode}`
                                    ? 'COPIED'
                                    : 'COPY PASSCODE'}
                                </span>
                              </button>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

          {ndaMode === 'sign' && (
            <>
              <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3 text-xs text-slate-300 leading-relaxed">
                <h2 className="text-sm font-bold text-amber-400">
                  🔒 SECTION 0: PRE-REGISTRATION INTELLECTUAL PROPERTY &amp; LEGAL NOTICE
                </h2>
                <p>
                  <strong className="text-white">
                    1. Unregistered Copyright &amp; Common-Law Intellectual Property Notice:
                  </strong>{' '}
                  Although formal registration with the U.S. Copyright Office and the U.S. Patent and Trademark Office (USPTO) is currently pending, automatic statutory copyright protection under the U.S. Copyright Act (17 U.S.C. § 102) attaches immediately upon creation and fixation of this original work. All aspects of ACT LIKE IT™—including its original 100+ parody scripts, the &ldquo;Tri-Modal Judging Engine&rdquo; architecture, the &ldquo;2.5D Boondocks-inspired&rdquo; cell-shaded visual style and 14 character archetypes, the &ldquo;Life Is Improv&rdquo; stealth HUD mechanics, custom UI/UX layouts, audio cues, source code, database schemas, and trade dress—are the exclusive, proprietary intellectual property of the Creator/Studio (© 2026 ACT LIKE IT Studio. All Rights Reserved. Common-Law Trademark ACT LIKE IT™ Claimed).
                </p>
                <p>
                  <strong className="text-white">
                    2. Strict Confidentiality, NDA, Manual Founder Approval &amp; Anti-Sharing Policy:
                  </strong>{' '}
                  By accessing the Closed Alpha build via{' '}
                  <span className="text-cyan-400 font-mono">
                    https://act-like-it.vercel.app
                  </span>{' '}
                  or the Android APK, you acknowledge and agree that this software is a Confidential Pre-Release Trade Secret. Signing below submits your dossier to Founder Corey Geter (
                  <span className="text-cyan-300 font-mono">
                    {FOUNDER_CONTACT_EMAIL}
                  </span>
                  ) for manual review. Once approved by the Founder, your{' '}
                  <strong className="text-amber-300">
                    UNIQUE PERSONAL TESTER PASSCODE (ALI-XX-XXXX)
                  </strong>{' '}
                  locked to your legal name and this specific device will be unlocked. Any attempt to use your passcode on another person&rsquo;s device immediately triggers an NDA Breach Alert under your name.
                </p>
              </div>

              <form
                onSubmit={handleSignNdaAndSubmitForApproval}
                className="space-y-4"
              >
                <h3 className="text-sm font-bold text-amber-400">
                  ✍️ TESTER &amp; POTENTIAL PARTNER LEGAL ACKNOWLEDGMENT &amp; DEVICE LOG
                </h3>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                  <div>
                    <label
                      htmlFor="nda-full-name"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Tester Full Legal Name *
                    </label>
                    <input
                      id="nda-full-name"
                      type="text"
                      value={ndaFullName}
                      onChange={(e) => setNdaFullName(e.target.value)}
                      placeholder="First & Last Legal Name"
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label
                      htmlFor="nda-email"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Personal / Business Email *
                    </label>
                    <input
                      id="nda-email"
                      type="email"
                      value={ndaEmail}
                      onChange={(e) => setNdaEmail(e.target.value)}
                      placeholder="name@example.com"
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label
                      htmlFor="nda-phone"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Tester Phone Number *
                    </label>
                    <input
                      id="nda-phone"
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
                    <label
                      htmlFor="nda-device-model"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Device Model *
                    </label>
                    <input
                      id="nda-device-model"
                      type="text"
                      value={ndaDevice}
                      onChange={(e) => setNdaDevice(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label
                      htmlFor="nda-os-version"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      OS Version *
                    </label>
                    <input
                      id="nda-os-version"
                      type="text"
                      value={ndaOsVersion}
                      onChange={(e) => setNdaOsVersion(e.target.value)}
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label
                      htmlFor="nda-network"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Network Connection Used *
                    </label>
                    <select
                      id="nda-network"
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
                      onChange={(e) =>
                        setNdaAgreedConfidential(e.target.checked)
                      }
                      className="mt-1 accent-amber-400"
                    />
                    <span>
                      I agree to the Strict Confidentiality &amp; Non-Disclosure Agreement (NDA): I will NOT share my personal tester passcode, publicly record, screenshot, share https://act-like-it.vercel.app or build files, or appropriate any game mechanics or scripts.
                    </span>
                  </label>
                </div>

                <div>
                  <label
                    htmlFor="nda-signature"
                    className="block text-xs font-bold text-amber-100 mb-1"
                  >
                    Tester Digital Signature (Type Full Legal Name) *
                  </label>
                  <input
                    id="nda-signature"
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
                          <label
                            key={track}
                            className="flex items-center gap-2 cursor-pointer"
                          >
                            <input
                              type="checkbox"
                              checked={ndaSelectedTracks.includes(track)}
                              onChange={(e) => {
                                if (e.target.checked) {
                                  setNdaSelectedTracks([
                                    ...ndaSelectedTracks,
                                    track,
                                  ]);
                                } else {
                                  setNdaSelectedTracks(
                                    ndaSelectedTracks.filter((t) => t !== track)
                                  );
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
                        onChange={(e) =>
                          setNdaBackgroundSummary(e.target.value)
                        }
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
                  STEP 1: SIGN NDA &amp; SUBMIT FOR FOUNDER APPROVAL
                </button>
              </form>
            </>
          )}

          {ndaMode !== 'admin' && (
            <>
              {/* PENDING FOUNDER APPROVAL CARD — Passcode strictly hidden until approved */}
              {currentTesterDossier &&
                currentTesterDossier.approval_status === 'pending' && (
                  <div className="bg-amber-950/50 border-2 border-amber-400 rounded-xl p-4 space-y-3">
                    <div className="text-xs font-mono font-black text-amber-300">
                      ⏳ NDA SIGNED — PENDING FOUNDER APPROVAL
                    </div>
                    <p className="text-xs text-amber-100 leading-relaxed">
                      Thank you,{' '}
                      <strong>{currentTesterDossier.full_legal_name}</strong>.
                      Your signed NDA and hardware device lock (
                      <code className="font-mono">{deviceFingerprint}</code>)
                      have been recorded in the approval queue.
                      <br />
                      <br />
                      🔒{' '}
                      <strong>
                        PASSCODE HELD FOR MANUAL FOUNDER CLEARANCE:
                      </strong>{' '}
                      Because the repository is public on GitHub, Founder Corey
                      Geter personally reviews and approves every tester before
                      their personal <code className="font-mono">ALI-XX-XXXX</code>{' '}
                      passcode is revealed or activated.
                    </p>
                    <div className="bg-slate-950 border border-slate-700 rounded-lg px-3 py-2.5 text-xs font-mono text-cyan-300 flex items-center justify-between">
                      <span>
                        Founder Direct Contact:{' '}
                        <strong>{FOUNDER_CONTACT_EMAIL}</strong>
                      </span>
                    </div>
                    {statusCheckMessage && (
                      <div className="text-xs font-bold text-amber-200">
                        {statusCheckMessage}
                      </div>
                    )}
                    <button
                      type="button"
                      onClick={handleCheckApprovalStatus}
                      className="w-full bg-slate-950 hover:bg-slate-900 border-2 border-cyan-400 text-cyan-300 font-mono font-black text-xs py-2.5 px-4 rounded-lg inline-flex items-center justify-center gap-2 transition-colors"
                    >
                      <RefreshCw className="w-3.5 h-3.5" />
                      <span>🔄 CHECK APPROVAL STATUS</span>
                    </button>
                  </div>
                )}

              {/* REJECTED BANNER */}
              {currentTesterDossier &&
                currentTesterDossier.approval_status === 'rejected' && (
                  <div className="bg-rose-950 border-2 border-rose-500 rounded-xl p-4 text-xs font-bold text-rose-200">
                    🚫 ACCESS DECLINED: Your Closed Alpha request was not
                    approved by Studio Administration ({FOUNDER_CONTACT_EMAIL}).
                  </div>
                )}

              {/* APPROVED PASSCODE CARD — Visible ONLY when approval_status === 'approved' */}
              {visibleApprovedPasscode && currentTesterDossier && (
                <div className="bg-emerald-950/60 border-2 border-emerald-400 rounded-xl p-4 space-y-3">
                  <div className="text-xs font-mono font-bold text-emerald-300">
                    ✅ FOUNDER APPROVED — YOUR UNIQUE PERSONAL PASSCODE IS ACTIVE
                  </div>
                  <div className="flex items-center justify-between bg-slate-950 border border-amber-400 rounded-lg px-4 py-3">
                    <span className="font-mono text-xl font-black tracking-widest text-amber-300">
                      {visibleApprovedPasscode}
                    </span>
                    <button
                      type="button"
                      onClick={() =>
                        handleCopyCode(
                          'nda-passcode',
                          visibleApprovedPasscode
                        )
                      }
                      className="text-xs font-mono font-bold text-cyan-300 hover:text-cyan-200 flex items-center gap-1"
                    >
                      {copiedPath === 'nda-passcode' ? (
                        <Check className="w-4 h-4" />
                      ) : (
                        <Copy className="w-4 h-4" />
                      )}
                      {copiedPath === 'nda-passcode'
                        ? 'COPIED'
                        : 'COPY PASSCODE'}
                    </button>
                  </div>
                  <p className="text-xs text-amber-200/90 leading-relaxed">
                    ⚠️ <strong>ANTI-SHARING TRACEABILITY WARNING:</strong> This
                    passcode (
                    <code className="font-mono">{visibleApprovedPasscode}</code>
                    ) is uniquely registered to{' '}
                    <strong>{currentTesterDossier.full_legal_name}</strong> and
                    locked to Device ID{' '}
                    <code className="font-mono">{deviceFingerprint}</code>. If
                    you give this passcode to anyone else, our system detects
                    the different device, blocks their access, and flags your
                    name and phone number with a CRITICAL NDA BREACH ALERT.
                  </p>
                </div>
              )}

              <form
                onSubmit={handleVerifyPasscodeAndUnlock}
                className="space-y-4"
              >
                <div className="bg-rose-950/40 border border-rose-500/70 rounded-xl p-4 space-y-2">
                  <label
                    htmlFor="step2-passcode-input"
                    className="block text-xs font-mono font-bold text-amber-300"
                  >
                    🔑 STEP 2: ENTER YOUR FOUNDER-APPROVED PASSCODE TO UNLOCK *
                  </label>
                  <input
                    id="step2-passcode-input"
                    type="text"
                    value={ndaPasscodeInput}
                    onChange={(e) => setNdaPasscodeInput(e.target.value)}
                    placeholder="e.g., ALI-JD-8492"
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
                  🔓 VERIFY APPROVED PASSCODE &amp; UNLOCK ACT LIKE IT™
                </button>
              </form>
            </>
          )}
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
              activeTab === 'files'
                ? 'text-white underline underline-offset-8'
                : ''
            }`}
          >
            All 5 Batches &amp; 100 Scenes
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('late-night')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'late-night'
                ? 'text-white underline underline-offset-8'
                : ''
            }`}
          >
            Late-Night 18+ Vault (10 Scenes)
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('sync-guide')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'sync-guide'
                ? 'text-white underline underline-offset-8'
                : ''
            }`}
          >
            Final GitHub Sync
          </button>
        </nav>

        <div className="flex items-center gap-3 shrink-0">
          <button
            type="button"
            onClick={() => {
              setNdaMode('admin');
              setNdaUnlocked(false);
            }}
            className="px-3.5 py-2 text-xs font-mono font-bold text-amber-300 bg-slate-900 border border-amber-400/60 rounded-lg hover:bg-slate-800 transition-colors whitespace-nowrap shrink-0"
          >
            🛡️ Founder Admin Console
          </button>
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
                  <span>Founder Executive Admin Portal</span>
                  <span aria-hidden="true"> · </span>
                  <span>Official Brand Logo Integrated</span>
                </div>
                <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
                  Founder Executive Admin Portal &amp; Manual Tester Approval Ready
                </h1>
                <p className="text-sm text-slate-300 leading-relaxed">
                  Configured <code className="font-mono text-amber-400">lib/auth/nda_tester_gate.dart</code> and <code className="font-mono text-amber-400">supabase/migrations/20261025000003_nda_tester_approvals.sql</code> with your dedicated Founder Admin Login (<code className="font-mono text-amber-300">admin88</code>), Executive Command Center Dashboard, KPI telemetry, and manual tester approval queue.
                </p>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4 shrink-0">
              <div className="px-4 py-3 rounded-lg bg-slate-950 border border-slate-800 text-right">
                <div className="text-xs text-slate-400">
                  Sequential Build Progress
                </div>
                <div className="text-xl font-bold font-mono tabular-nums text-emerald-400">
                  {progress.completedCount} / {progress.totalCount} Batches (
                  {progress.percentage}%)
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
                  Complete Flutter &amp; Supabase Repository
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
                          <span className="font-mono text-xs truncate">
                            {file.path}
                          </span>
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
                  onClick={() =>
                    handleCopyCode(selectedFile.path, selectedFile.content)
                  }
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
                Simulates{' '}
                <code className="font-mono text-amber-400">
                  verify_player_age_and_unlock_late_night
                </code>{' '}
                RPC &amp; PostgreSQL RLS policy on{' '}
                <code className="font-mono text-amber-400">
                  public.scenes_late_night_after_hours
                </code>
                .
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
                    <span>Verify 18+ &amp; Unlock Vault</span>
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
                    After-Hours Prompt Vault &amp; 15s Mid-Take Twists
                  </h3>
                  <p className="text-xs text-slate-400">
                    Table:{' '}
                    <code className="font-mono">
                      public.scenes_late_night_after_hours
                    </code>
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
                    Verify your birth year (18+) and 4-digit PIN on the left to
                    execute{' '}
                    <code className="font-mono text-amber-400">
                      verify_player_age_and_unlock_late_night
                    </code>{' '}
                    and reveal the After-Hours prompts.
                  </p>
                </div>
              ) : (
                <div className="space-y-3">
                  {LATE_NIGHT_PROMPTS.filter(
                    (p) => p.spiceTier <= selectedSpiceTier
                  ).map((prompt) => {
                    const twistActive = twistTriggeredId === prompt.id;
                    return (
                      <div
                        key={prompt.id}
                        className="p-4 rounded-xl bg-slate-950 border border-slate-800 space-y-2.5"
                      >
                        <div className="flex items-center justify-between gap-2 text-xs">
                          <span className="font-mono text-rose-400">
                            SPICE TIER {prompt.spiceTier} ({prompt.multiplier}) ·{' '}
                            {prompt.advisory}
                          </span>
                          <button
                            type="button"
                            onClick={() =>
                              setTwistTriggeredId(
                                twistActive ? null : prompt.id
                              )
                            }
                            className="inline-flex items-center gap-1 px-2.5 py-1 text-xs font-semibold rounded bg-slate-800 hover:bg-slate-700 text-amber-400 transition-colors whitespace-nowrap shrink-0"
                          >
                            <Zap className="w-3 h-3" />
                            <span>
                              {twistActive
                                ? 'Hide 15s Twist'
                                : 'Trigger 15s Twist'}
                            </span>
                          </button>
                        </div>

                        <div className="text-sm font-bold text-white">
                          {prompt.title} · {prompt.film} ({prompt.year}) —{' '}
                          {prompt.character}
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
                  })}
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
                Configured{' '}
                <code className="font-mono text-amber-400">
                  .github/workflows/build_apk.yml
                </code>{' '}
                (<code className="font-mono text-white">Build and Release APK</code>)
                with Zulu Java 17, Flutter stable,{' '}
                <code className="font-mono text-amber-400">--dart-define</code>{' '}
                secret injection, and{' '}
                <code className="font-mono text-amber-400">
                  actions/upload-artifact@v4
                </code>
                :
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">
                  01. Push Workflow to GitHub
                </div>
                <h3 className="text-base font-semibold text-white">
                  Tap &ldquo;Push Changes&rdquo; in AI Studio
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Open the Settings &rarr; GitHub tab in AI Studio and push to
                  your <code className="font-mono text-white">main</code>{' '}
                  branch. Pushing triggers{' '}
                  <code className="font-mono text-white">
                    .github/workflows/build_apk.yml
                  </code>{' '}
                  on GitHub Actions.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">
                  02. Open GitHub Actions
                </div>
                <h3 className="text-base font-semibold text-white">
                  Download act-like-it-apk
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Open your <code className="font-mono text-white">act_like_it</code>{' '}
                  repo on your S26 Ultra browser, tap the{' '}
                  <strong className="text-white">Actions</strong> tab, select
                  the completed{' '}
                  <strong className="text-white">Build and Release APK</strong>{' '}
                  run, and download{' '}
                  <code className="font-mono text-white">act-like-it-apk</code>{' '}
                  (<code className="font-mono text-white">app-release.apk</code>).
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-emerald-400">
                  03. Secrets &amp; Standalone Ready
                </div>
                <h3 className="text-base font-semibold text-white">
                  100% Functional on Galaxy S26 Ultra
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Add <code className="font-mono text-white">SUPABASE_URL</code>,{' '}
                  <code className="font-mono text-white">SUPABASE_ANON_KEY</code>
                  , <code className="font-mono text-white">LIVEKIT_URL</code>,
                  and{' '}
                  <code className="font-mono text-white">GEMINI_API_KEY</code>{' '}
                  in GitHub Settings &rarr; Secrets &rarr; Actions (or configure
                  them live inside the app).
                </p>
              </div>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}
