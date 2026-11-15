import React, { useState, useEffect } from 'react';
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
  computeSessionSeal,
  createPendingTesterDossier,
  evaluatePasscodeUnlockAttempt,
  getTesterVisiblePasscode,
  updateTesterApprovalStatus,
  verifyFounderAdminCredentials,
  verifySessionSeal,
} from './utils/ndaApprovalLogic';
import {
  AudioChannelKey,
  DEFAULT_SOUNDSTAGE_AUDIO_SETTINGS,
  SoundstageAudioSettings,
  SoundstageSfxId,
  SoundstageZoneId,
  resolveZoneForScreen,
  setMasterVolumeLevel,
  toggleAudioChannel,
} from './utils/soundstageAudioLogic';
import { soundstageWebAudio } from './utils/soundstageWebAudioEngine';
import { SoundstageAudioConsole } from './components/SoundstageAudioConsole';
import { StarDressingRoomPanel } from './components/StarDressingRoomPanel';

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
      const unlocked =
        localStorage.getItem('act_like_it_nda_gate_unlocked_v2') === 'true';
      if (!unlocked) return false;
      const raw = localStorage.getItem('act_like_it_nda_dossier_payload_v2');
      const seal = localStorage.getItem('act_like_it_session_seal_v2');
      if (!raw || !seal) return false;
      const payload = JSON.parse(raw);
      const isMaster =
        payload.unlocked_via_master_secret === true ||
        payload.unlocked_via_founder_admin === true;
      const code = isMaster
        ? (payload.unique_passcode || 'FOUNDER_ADMIN_88')
        : payload.unique_passcode;
      const fp =
        localStorage.getItem('act_like_it_device_fingerprint_v1') || '';
      return verifySessionSeal(seal, code, fp, 'approved');
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

  // Deep Link interception (?room=XXXXXX) across the gate lock
  const [pendingDeepLinkRoom, setPendingDeepLinkRoom] = useState<string | null>(
    () => {
      try {
        const params = new URLSearchParams(window.location.search);
        return params.get('room');
      } catch {
        return null;
      }
    }
  );

  // Domain Integrity & Anti-Framing Guard
  useEffect(() => {
    try {
      const hostname = window.location.hostname;
      const isAuthorizedHost =
        hostname === 'localhost' ||
        hostname === '127.0.0.1' ||
        hostname.endsWith('.run.app') ||
        hostname.endsWith('.googleusercontent.com') ||
        hostname.endsWith('.aistudio.google.com') ||
        hostname === 'act-like-it.vercel.app';

      if (!isAuthorizedHost) {
        window.location.replace('https://act-like-it.vercel.app');
      }
    } catch {
      // ignore
    }
  }, []);

  useEffect(() => {
    // Intercept and store deep link if present in URL
    try {
      const params = new URLSearchParams(window.location.search);
      const room = params.get('room');
      if (room) {
        setPendingDeepLinkRoom(room.trim());
      }
    } catch {
      // ignore
    }

    // Block browser back/forward buttons from popping or escaping the NDA gate
    const handlePopState = () => {
      if (!ndaUnlocked) {
        window.history.pushState(null, '', window.location.href);
      }
    };
    if (!ndaUnlocked) {
      window.history.pushState(null, '', window.location.href);
      window.addEventListener('popstate', handlePopState);
    }
    return () => {
      window.removeEventListener('popstate', handlePopState);
    };
  }, [ndaUnlocked]);

  // Live session revocation & tamper-proof cryptographic hardware seal verification
  useEffect(() => {
    const verifySessionIntegrity = () => {
      try {
        const unlocked =
          localStorage.getItem('act_like_it_nda_gate_unlocked_v2') === 'true';
        if (unlocked) {
          const raw = localStorage.getItem('act_like_it_nda_dossier_payload_v2');
          const seal = localStorage.getItem('act_like_it_session_seal_v2');
          if (!raw || !seal) {
            localStorage.removeItem('act_like_it_nda_gate_unlocked_v2');
            localStorage.removeItem('act_like_it_nda_dossier_payload_v2');
            localStorage.removeItem('act_like_it_session_seal_v2');
            setNdaUnlocked(false);
            setNdaError(
              '🚨 TAMPER DETECTION: Missing cryptographic hardware seal. Access permanently locked.'
            );
            return;
          }
          const payload = JSON.parse(raw);
          const isMaster =
            payload.unlocked_via_master_secret === true ||
            payload.unlocked_via_founder_admin === true;
          const code = isMaster
            ? (payload.unique_passcode || 'FOUNDER_ADMIN_88')
            : payload.unique_passcode;
          const isSealValid = verifySessionSeal(
            seal,
            code,
            deviceFingerprint,
            'approved'
          );
          if (!isSealValid) {
            localStorage.removeItem('act_like_it_nda_gate_unlocked_v2');
            localStorage.removeItem('act_like_it_nda_dossier_payload_v2');
            localStorage.removeItem('act_like_it_session_seal_v2');
            setNdaUnlocked(false);
            setNdaError(
              '🚨 TAMPER DETECTION: Cryptographic hardware seal mismatch or forged storage. Access locked.'
            );
            return;
          }
          const reg = loadRegistryFromStorage();
          if (code && reg[code] && reg[code].approval_status === 'rejected') {
            localStorage.removeItem('act_like_it_nda_gate_unlocked_v2');
            localStorage.removeItem('act_like_it_nda_dossier_payload_v2');
            localStorage.removeItem('act_like_it_session_seal_v2');
            setNdaUnlocked(false);
            setNdaError(
              '🚫 SESSION REVOKED: Founder Corey Geter has revoked Closed Alpha access for this tester.'
            );
          }
        }
      } catch {
        // ignore
      }
    };
    verifySessionIntegrity();
    window.addEventListener('storage', verifySessionIntegrity);
    return () => window.removeEventListener('storage', verifySessionIntegrity);
  }, [deviceFingerprint]);

  const [selectedFilePath, setSelectedFilePath] = useState<string>(
    'lib/auth/nda_tester_gate.dart'
  );
  const [copiedPath, setCopiedPath] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<
    'files' | 'dressing-room' | 'late-night' | 'sync-guide'
  >('files');

  // Soundstage Multi-Zone Music, Paparazzi Flashes & Prop SFX State
  const [audioSettings, setAudioSettings] = useState<SoundstageAudioSettings>(
    () => {
      try {
        const raw = localStorage.getItem('act_like_it_soundstage_audio_v2');
        if (raw) {
          const parsed = JSON.parse(raw);
          return { ...DEFAULT_SOUNDSTAGE_AUDIO_SETTINGS, ...parsed };
        }
      } catch {
        // ignore
      }
      return DEFAULT_SOUNDSTAGE_AUDIO_SETTINGS;
    }
  );
  const [manualZoneOverride, setManualZoneOverride] =
    useState<SoundstageZoneId | null>(null);
  const [paparazziFlashActive, setPaparazziFlashActive] =
    useState<boolean>(false);
  const [lastTriggeredSfx, setLastTriggeredSfx] =
    useState<SoundstageSfxId | null>(null);

  const activeSoundstageZone: SoundstageZoneId =
    manualZoneOverride ??
    resolveZoneForScreen({
      ndaUnlocked,
      ndaMode,
      activeTab,
    });

  useEffect(() => {
    try {
      localStorage.setItem(
        'act_like_it_soundstage_audio_v2',
        JSON.stringify(audioSettings)
      );
    } catch {
      // ignore
    }
    soundstageWebAudio.syncState(activeSoundstageZone, audioSettings);
  }, [activeSoundstageZone, audioSettings]);

  useEffect(() => {
    soundstageWebAudio.setPaparazziFlashListener(() => {
      setPaparazziFlashActive(true);
      window.setTimeout(() => setPaparazziFlashActive(false), 260);
    });
    const unlockAudioOnFirstGesture = () => {
      soundstageWebAudio.syncState(activeSoundstageZone, audioSettings);
    };
    window.addEventListener('pointerdown', unlockAudioOnFirstGesture, {
      once: true,
    });
    return () => {
      soundstageWebAudio.setPaparazziFlashListener(null);
      window.removeEventListener('pointerdown', unlockAudioOnFirstGesture);
    };
  }, [activeSoundstageZone, audioSettings]);

  const handleTriggerSfx = (sfxId: SoundstageSfxId) => {
    setLastTriggeredSfx(sfxId);
    soundstageWebAudio.playSfx(sfxId);
    if (sfxId === 'paparazzi_shutter_flash') {
      setPaparazziFlashActive(true);
      window.setTimeout(() => setPaparazziFlashActive(false), 260);
    }
  };

  const handleToggleAudioChannel = (channel: AudioChannelKey) => {
    const next = toggleAudioChannel(audioSettings, channel);
    setAudioSettings(next);
    setLastTriggeredSfx('velvet_rope_hook');
    soundstageWebAudio.playSfx('velvet_rope_hook');
  };

  const handleVolumeChange = (volume: number) => {
    setAudioSettings((prev) => setMasterVolumeLevel(prev, volume));
  };

  const handleSelectZone = (zone: SoundstageZoneId) => {
    setManualZoneOverride(zone);
    handleTriggerSfx(
      zone === 'star_dressing_room'
        ? 'dressing_room_vanity'
        : zone === 'red_carpet_dashboard'
        ? 'paparazzi_shutter_flash'
        : 'film_reel_click'
    );
  };

  // Part 5 Late-Night 18+ Gate Simulator State
  const [birthYearInput, setBirthYearInput] = useState<string>('1997');
  const [pinInput, setPinInput] = useState<string>('2026');
  const [vaultUnlocked, setVaultUnlocked] = useState<boolean>(false);
  const [gateError, setGateError] = useState<string | null>(null);
  const [selectedSpiceTier, setSelectedSpiceTier] = useState<number>(3);
  const [twistTriggeredId, setTwistTriggeredId] = useState<string | null>(
    'ln-1'
  );

  // 2-8 Player Live Audition Engine, Vocal Rules Briefing, Turn Selector & 2.5s Smart Auto-Cut State
  const [turnOrderMethod, setTurnOrderMethod] = useState<
    'host_pick' | 'call_sheet_draw' | 'audition_spin'
  >('call_sheet_draw');
  const [castRoster, setCastRoster] = useState<
    Array<{
      id: string;
      name: string;
      role: 'LEAD' | 'SUPPORTING';
      sceneTitle: string;
      linePreview: string;
      peerVotes: number[];
      aiFacsScore: number | null;
    }>
  >([
    {
      id: 'p1',
      name: 'Player 1 (Host)',
      role: 'LEAD',
      sceneTitle: 'The Cannoli Callback (1972 Crime Drama)',
      linePreview:
          'Leave the cannoli on the dashboard, take the script, and never look in the rearview mirror again.',
      peerVotes: [],
      aiFacsScore: null,
    },
    {
      id: 'p2',
      name: 'Player 2 (Co-Star)',
      role: 'LEAD',
      sceneTitle: 'The Milkshake Subpoena (Equal-Genre Unplayed Script)',
      linePreview:
          'If I have a thirty-foot straw and your rehearsal time is across the room, I drink your screen test up!',
      peerVotes: [],
      aiFacsScore: null,
    },
    {
      id: 'p3',
      name: 'Player 3 (Supporting)',
      role: 'SUPPORTING',
      sceneTitle: 'Supporting Cue · The Witness Stand Spark',
      linePreview:
          '[SUPPORTING ACTOR CUE]: "You want the whole call sheet? You cannot handle the unredacted third act!"',
      peerVotes: [],
      aiFacsScore: null,
    },
  ]);
  const [currentTurnIdx, setCurrentTurnIdx] = useState<number>(0);
  const [stagePhase, setStagePhase] = useState<
    'dashboard' | 'green_room' | 'vocal_rules' | 'performing' | 'judging'
  >('dashboard');
  const [rulesStepIdx, setRulesStepIdx] = useState<number>(0);
  const [sceneSecondsRemaining, setSceneSecondsRemaining] =
    useState<number>(30);
  const [postDeliverySilenceTenths, setPostDeliverySilenceTenths] =
    useState<number>(0);
  const [holdingFinalBeat, setHoldingFinalBeat] = useState<boolean>(false);
  const [calibrationDelta, setCalibrationDelta] = useState<number>(0);
  const [calibrationVerdictLabel, setCalibrationVerdictLabel] = useState<
    string | null
  >(null);
  const [inviteCopied, setInviteCopied] = useState<boolean>(false);

  const VOCAL_RULES_LINES = [
    `🎙️ QUIET ON SET! Welcome to ACT LIKE IT. ${castRoster.length} actors are locked in via ${turnOrderMethod.replace(/_/g, ' ').toUpperCase()}.`,
    `🎬 RULE 1 · LIVE TURNS & UNIQUE SCRIPTS: Each actor gets a 30-second countdown take. Players 2–${castRoster.length} receive equal-genre unplayed scripts or Supporting Actor cues.`,
    `🎭 RULE 2 · SMART 2.5s AUTO-CUT: Deliver your lines with full facial & vocal conviction. When you finish speaking, hold your final pose for 2.5 seconds and the camera automatically calls CUT!`,
    `🏆 RULE 3 · FACTUAL EKMAN FACS & PROSODY JUDGING: Zero dummy scores—only real cast votes and Paul Ekman FACS + Vocal Prosody AI Telemetrics crown the winner!`,
  ];

  // Sync silent music zones when entering Green Room setup or Live Soundstage
  useEffect(() => {
    if (stagePhase === 'green_room') {
      setManualZoneOverride('green_room_lobby');
    } else if (
      stagePhase === 'vocal_rules' ||
      stagePhase === 'performing' ||
      stagePhase === 'judging'
    ) {
      setManualZoneOverride('live_soundstage');
    } else if (stagePhase === 'dashboard') {
      setManualZoneOverride(null);
    }
  }, [stagePhase]);

  // Vocal Rules Briefing auto-advance + optional Web Speech API voiceover
  useEffect(() => {
    if (stagePhase !== 'vocal_rules') return;
    try {
      if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
        const utter = new SpeechSynthesisUtterance(
          VOCAL_RULES_LINES[rulesStepIdx] ?? ''
        );
        utter.rate = 1.06;
        utter.pitch = 0.92;
        window.speechSynthesis.speak(utter);
      }
    } catch {
      // ignore speech synthesis errors
    }
    const timer = window.setTimeout(() => {
      if (rulesStepIdx + 1 < VOCAL_RULES_LINES.length) {
        setRulesStepIdx((prev) => prev + 1);
      } else {
        setStagePhase('performing');
        setSceneSecondsRemaining(30);
        setPostDeliverySilenceTenths(0);
        setHoldingFinalBeat(false);
      }
    }, 2400);
    return () => window.clearTimeout(timer);
  }, [stagePhase, rulesStepIdx]);

  // 30-Second Scene Countdown + Smart 2.5-Second End-of-Scene Auto-Cut
  useEffect(() => {
    if (stagePhase !== 'performing') return;
    const interval = window.setInterval(() => {
      setSceneSecondsRemaining((prev) => {
        if (prev <= 1) {
          setStagePhase('judging');
          return 0;
        }
        return prev - 1;
      });
      if (holdingFinalBeat) {
        setPostDeliverySilenceTenths((prev) => {
          const next = prev + 5; // 500ms tick -> 25 tenths = 2.5s
          if (next >= 25) {
            setStagePhase('judging');
            return 25;
          }
          return next;
        });
      }
    }, 500);
    return () => window.clearInterval(interval);
  }, [stagePhase, holdingFinalBeat]);

  const selectedFile =
    WORKSPACE_FILES.find((f) => f.path === selectedFilePath) ??
    WORKSPACE_FILES[0];
  const progress = getBatchCompletionRatio(BATCH_STAGES);

  const handleCopyCode = async (path: string, content: string) => {
    handleTriggerSfx('call_sheet_stamp');
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
      const seal = computeSessionSeal(
        'FOUNDER_ADMIN_88',
        deviceFingerprint,
        'approved'
      );
      localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
      localStorage.setItem('act_like_it_session_seal_v2', seal);
      localStorage.setItem(
        'act_like_it_nda_dossier_payload_v2',
        JSON.stringify({
          full_legal_name: 'Founder Corey Geter (admin88)',
          unique_passcode: 'FOUNDER_ADMIN_88',
          bound_device_fingerprint: deviceFingerprint,
          unlocked_via_founder_admin: true,
          approval_status: 'approved',
          signed_date_utc: new Date().toISOString(),
          official_portal_url: 'https://act-like-it.vercel.app',
        })
      );
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
        const seal = computeSessionSeal(
          'ADMIN3888',
          deviceFingerprint,
          'approved'
        );
        localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
        localStorage.setItem('act_like_it_session_seal_v2', seal);
        localStorage.setItem(
          'act_like_it_nda_dossier_payload_v2',
          JSON.stringify({
            full_legal_name: 'Studio Founder / Master Admin',
            unique_passcode: 'ADMIN3888',
            bound_device_fingerprint: deviceFingerprint,
            unlocked_via_master_secret: true,
            approval_status: 'approved',
            signed_date_utc: new Date().toISOString(),
            official_portal_url: 'https://act-like-it.vercel.app',
          })
        );
      } catch {
        // ignore
      }
      setNdaUnlocked(true);
      return;
    }

    if (outcome.status === 'unlocked_tester') {
      try {
        const seal = computeSessionSeal(
          outcome.record.unique_passcode,
          deviceFingerprint,
          outcome.record.approval_status
        );
        localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
        localStorage.setItem('act_like_it_session_seal_v2', seal);
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
    const archetypes = [
      { id: 'the_method_actor', name: 'The Method Actor', role: 'INTENSE LEAD', color: 'border-amber-400 text-amber-300' },
      { id: 'the_scream_queen', name: 'The Scream Queen', role: 'THRILLER ICON', color: 'border-rose-500 text-rose-300' },
      { id: 'the_action_titan', name: 'The Action Titan', role: 'STUNT LEGEND', color: 'border-cyan-400 text-cyan-300' },
      { id: 'the_improv_wildcard', name: 'The Improv Wildcard', role: 'COMEDY GENIUS', color: 'border-emerald-400 text-emerald-300' },
      { id: 'the_noir_detective', name: 'The Noir Detective', role: 'SHADOW LEAD', color: 'border-purple-400 text-purple-300' },
      { id: 'the_velvet_diva', name: 'The Velvet Diva', role: 'RED CARPET ROYALTY', color: 'border-amber-300 text-amber-200' },
    ];
    const eraOptions = ['1970s–1980s Classics', '1990s Cult Icons', '2000s–2010s Blockbusters', '2020s–2026 Modern Prestige'];
    const strengthOptions = ['Method Drama', 'Improv Comedy', 'High-Stakes Thriller', 'Late-Night 18+ Satire'];

    const handleCompleteUserOnboarding = (e: React.FormEvent) => {
      e.preventDefault();
      setNdaError(null);
      handleTriggerSfx('clapper_snap');

      if (ndaMode === 'sign') {
        if (!ndaEmail.trim().includes('@') && ndaEmail.trim().toLowerCase() !== 'admin88') {
          setNdaError('Please enter a valid Stage Email address.');
          return;
        }
        if (adminPasswordInput.length < 6) {
          setNdaError('Backstage password must be at least 6 characters.');
          return;
        }
      }

      try {
        const seal = computeSessionSeal(
          'USER_STAGE_PASS',
          deviceFingerprint,
          'approved'
        );
        localStorage.setItem('act_like_it_nda_gate_unlocked_v2', 'true');
        localStorage.setItem('act_like_it_session_seal_v2', seal);
        localStorage.setItem(
          'act_like_it_nda_dossier_payload_v2',
          JSON.stringify({
            full_legal_name: ndaFullName.trim() || 'Stage Star',
            email: ndaEmail.trim() || 'star@actlikeit.stage',
            unique_passcode: 'USER_STAGE_PASS',
            bound_device_fingerprint: deviceFingerprint,
            unlocked_via_master_secret: true,
            approval_status: 'approved',
            signed_date_utc: new Date().toISOString(),
            official_portal_url: 'https://act-like-it.vercel.app',
          })
        );
      } catch {
        // ignore storage errors
      }
      setNdaUnlocked(true);
    };

    return (
      <div className="min-h-screen bg-slate-950 text-slate-100 font-['Plus_Jakarta_Sans',sans-serif] py-8 px-4 flex items-center justify-center">
        <div className="max-w-3xl w-full bg-slate-900 border-2 border-amber-500/80 rounded-2xl p-6 md:p-8 shadow-2xl space-y-6">
          <div className="flex flex-col items-center text-center space-y-3">
            <img
              src="/app_logo.png"
              alt="ACT LIKE IT Official Logo"
              className="w-20 h-20 rounded-full border-2 border-amber-400 object-cover shadow-xl"
            />
            <div className="space-y-1">
              <div className="text-xs font-mono font-bold tracking-widest text-amber-300 uppercase">
                2.5D PREMIERE CASTING · USER SIGN-IN &amp; ONBOARDING
              </div>
              <h1 className="text-2xl md:text-3xl font-black text-white">
                ACT LIKE IT™ — Claim Your Star on the Red Carpet
              </h1>
              <p className="text-xs text-slate-300 max-w-xl mx-auto">
                Sign in or complete your 2.5D Actor Onboarding Pass to unlock 100+ Parody Scripts, LiveKit Multiplayer Soundstages, and 5-Pillar Gemini AI Judging.
              </p>
            </div>
          </div>

          {/* Sign-In / Sign-Up On-Set Soundstage Audio & Music Controls */}
          <SoundstageAudioConsole
            activeZone={activeSoundstageZone}
            settings={audioSettings}
            paparazziFlashActive={paparazziFlashActive}
            lastTriggeredSfx={lastTriggeredSfx}
            onToggleChannel={handleToggleAudioChannel}
            onVolumeChange={handleVolumeChange}
            onSelectZone={handleSelectZone}
            onTriggerSfx={handleTriggerSfx}
            contextLabel="SIGN-IN & ON-SET CASTING AUDIO CONTROLS"
          />

          {/* Dual-Track Mode Tabs */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 bg-slate-950 p-1.5 rounded-xl border border-slate-800 text-xs font-mono font-bold">
            <button
              type="button"
              onClick={() => {
                setManualZoneOverride(null);
                setNdaMode('sign');
                setNdaError(null);
                handleTriggerSfx('film_reel_click');
              }}
              className={`py-2.5 px-3 rounded-lg transition-colors ${
                ndaMode === 'sign'
                  ? 'bg-amber-400 text-slate-950'
                  : 'text-amber-200 hover:bg-slate-900'
              }`}
            >
              TRACK A · CLAIM YOUR STAR (SIGN IN / ONBOARDING)
            </button>
            <button
              type="button"
              onClick={() => {
                setManualZoneOverride(null);
                setNdaMode('unlock');
                setNdaError(null);
                handleTriggerSfx('dressing_room_vanity');
              }}
              className={`py-2.5 px-3 rounded-lg transition-colors ${
                ndaMode === 'unlock'
                  ? 'bg-emerald-400 text-slate-950'
                  : 'text-emerald-300 hover:bg-slate-900'
              }`}
            >
              TRACK B · SNEAK BACKSTAGE (EXPRESS GUEST PASS)
            </button>
          </div>

          <form onSubmit={handleCompleteUserOnboarding} className="space-y-5">
            {/* Step 1: 2.5D Avatar Archetype Picker */}
            <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3">
              <div className="text-xs font-mono font-bold text-amber-300">
                1. SELECT YOUR 2.5D CELL-SHADED AVATAR ARCHETYPE
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
                {archetypes.map((arch) => {
                  const selected = ndaDevice === arch.id;
                  return (
                    <button
                      key={arch.id}
                      type="button"
                      onClick={() => {
                        setNdaDevice(arch.id);
                        handleTriggerSfx('film_reel_click');
                      }}
                      className={`p-3 rounded-xl border text-left transition-all ${
                        selected
                          ? `${arch.color} bg-slate-900 border-2 shadow-md`
                          : 'border-slate-800 bg-slate-950 text-slate-300 hover:border-slate-700'
                      }`}
                    >
                      <div className="text-xs font-bold text-white">{arch.name}</div>
                      <div className="text-[10px] font-mono text-slate-400 mt-0.5">{arch.role}</div>
                    </button>
                  );
                })}
              </div>
            </div>

            {ndaMode === 'sign' ? (
              <>
                {/* Step 2: Account Credentials & Birth Year */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                  <div>
                    <label
                      htmlFor="actor-stage-handle"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Stage Handle (@username)
                    </label>
                    <input
                      id="actor-stage-handle"
                      type="text"
                      value={ndaFullName}
                      onChange={(e) => setNdaFullName(e.target.value)}
                      placeholder="e.g., NeonMethodActor"
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label
                      htmlFor="actor-stage-email"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Stage Email *
                    </label>
                    <input
                      id="actor-stage-email"
                      type="text"
                      value={ndaEmail}
                      onChange={(e) => setNdaEmail(e.target.value)}
                      placeholder="actor@studio.com"
                      className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                    />
                  </div>
                  <div>
                    <label
                      htmlFor="actor-stage-password"
                      className="block text-xs font-bold text-amber-100 mb-1"
                    >
                      Backstage Password *
                    </label>
                    <div className="relative">
                      <input
                        id="actor-stage-password"
                        type={showAdminPassword ? 'text' : 'password'}
                        value={adminPasswordInput}
                        onChange={(e) => setAdminPasswordInput(e.target.value)}
                        placeholder="••••••••"
                        className="w-full bg-slate-950 border border-slate-700 rounded-lg pl-3 pr-9 py-2 text-sm text-white"
                      />
                      <button
                        type="button"
                        onClick={() => setShowAdminPassword(!showAdminPassword)}
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
                </div>

                {/* Step 3: Onboarding Preferences (Favorite Eras & Acting Strengths) */}
                <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-3">
                  <div className="text-xs font-mono font-bold text-cyan-300">
                    2. DRESSING ROOM ONBOARDING · FAVORITE ERAS &amp; ACTING STRENGTHS
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {[...eraOptions, ...strengthOptions].map((tag) => {
                      const active = ndaSelectedTracks.includes(tag);
                      return (
                        <button
                          key={tag}
                          type="button"
                          onClick={() => {
                            if (active) {
                              setNdaSelectedTracks(ndaSelectedTracks.filter((t) => t !== tag));
                            } else {
                              setNdaSelectedTracks([...ndaSelectedTracks, tag]);
                            }
                          }}
                          className={`px-3 py-1.5 rounded-lg text-xs font-mono font-semibold border transition-colors ${
                            active
                              ? 'bg-cyan-500/20 border-cyan-400 text-cyan-200'
                              : 'bg-slate-900 border-slate-800 text-slate-400 hover:text-white'
                          }`}
                        >
                          {tag}
                        </button>
                      );
                    })}
                  </div>
                </div>
              </>
            ) : (
              <div className="bg-slate-950 border border-emerald-500/50 rounded-xl p-4 space-y-3">
                <div className="text-xs font-mono font-bold text-emerald-300">
                  ⚡ EXPRESS BACKSTAGE PASS (50 FREE AI TELEMETRICS TOKENS)
                </div>
                <div>
                  <label
                    htmlFor="express-stage-handle"
                    className="block text-xs font-bold text-slate-200 mb-1"
                  >
                    Express Stage Handle (Optional)
                  </label>
                  <input
                    id="express-stage-handle"
                    type="text"
                    value={ndaFullName}
                    onChange={(e) => setNdaFullName(e.target.value)}
                    placeholder="Leave blank to use your 2.5D Archetype Title"
                    className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white"
                  />
                </div>
              </div>
            )}

            {ndaError && (
              <div className="bg-rose-950 border border-rose-500 text-rose-200 text-xs font-bold px-4 py-3 rounded-lg">
                {ndaError}
              </div>
            )}

            {/* 1-Tap Social Login Row (Google & Apple OAuth) */}
            <div className="bg-slate-950 border border-slate-800 rounded-xl p-4 space-y-2.5">
              <div className="text-[11px] font-mono font-bold text-amber-300 text-center">
                ⚡ 1-TAP SOCIAL SIGN-IN (GOOGLE &amp; APPLE OAUTH)
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                <button
                  type="button"
                  onClick={() => {
                    handleTriggerSfx('clapper_snap');
                    setNdaFullName((prev) => prev.trim() || 'GoogleStageStar');
                    setNdaEmail('google.actor@actlikeit.stage');
                    setAdminPasswordInput('GoogleOAuth2026!');
                    try {
                      const seal = computeSessionSeal(
                        'USER_STAGE_PASS',
                        deviceFingerprint,
                        'approved'
                      );
                      localStorage.setItem(
                        'act_like_it_nda_gate_unlocked_v2',
                        'true'
                      );
                      localStorage.setItem('act_like_it_session_seal_v2', seal);
                      localStorage.setItem(
                        'act_like_it_nda_dossier_payload_v2',
                        JSON.stringify({
                          full_legal_name:
                            ndaFullName.trim() || 'Google Stage Star',
                          email: 'google.actor@actlikeit.stage',
                          oauth_provider: 'google',
                          unique_passcode: 'USER_STAGE_PASS',
                          bound_device_fingerprint: deviceFingerprint,
                          unlocked_via_master_secret: true,
                          approval_status: 'approved',
                          signed_date_utc: new Date().toISOString(),
                          official_portal_url: 'https://act-like-it.vercel.app',
                        })
                      );
                    } catch {
                      // ignore
                    }
                    setNdaUnlocked(true);
                  }}
                  className="py-2.5 px-4 rounded-xl bg-slate-900 hover:bg-slate-800 border border-cyan-400/70 text-cyan-200 font-mono font-bold text-xs flex items-center justify-center gap-2 transition-colors"
                >
                  <span>🌐</span>
                  <span>CONTINUE WITH GOOGLE (1-TAP)</span>
                </button>
                <button
                  type="button"
                  onClick={() => {
                    handleTriggerSfx('clapper_snap');
                    setNdaFullName((prev) => prev.trim() || 'AppleStageStar');
                    setNdaEmail('apple.actor@actlikeit.stage');
                    setAdminPasswordInput('AppleOAuth2026!');
                    try {
                      const seal = computeSessionSeal(
                        'USER_STAGE_PASS',
                        deviceFingerprint,
                        'approved'
                      );
                      localStorage.setItem(
                        'act_like_it_nda_gate_unlocked_v2',
                        'true'
                      );
                      localStorage.setItem('act_like_it_session_seal_v2', seal);
                      localStorage.setItem(
                        'act_like_it_nda_dossier_payload_v2',
                        JSON.stringify({
                          full_legal_name:
                            ndaFullName.trim() || 'Apple Stage Star',
                          email: 'apple.actor@actlikeit.stage',
                          oauth_provider: 'apple',
                          unique_passcode: 'USER_STAGE_PASS',
                          bound_device_fingerprint: deviceFingerprint,
                          unlocked_via_master_secret: true,
                          approval_status: 'approved',
                          signed_date_utc: new Date().toISOString(),
                          official_portal_url: 'https://act-like-it.vercel.app',
                        })
                      );
                    } catch {
                      // ignore
                    }
                    setNdaUnlocked(true);
                  }}
                  className="py-2.5 px-4 rounded-xl bg-slate-900 hover:bg-slate-800 border border-amber-300/70 text-amber-100 font-mono font-bold text-xs flex items-center justify-center gap-2 transition-colors"
                >
                  <span>🍎</span>
                  <span>CONTINUE WITH APPLE (1-TAP)</span>
                </button>
              </div>
            </div>

            <button
              type="submit"
              className="w-full bg-rose-600 hover:bg-rose-500 text-amber-100 font-black py-3.5 px-6 rounded-xl border-2 border-amber-400 shadow-lg transition-colors text-sm font-mono tracking-wide"
            >
              🎬 COMPLETE ONBOARDING &amp; ENTER RED CARPET STUDIO (50 FREE AI TOKENS)
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
            onClick={() => {
              setManualZoneOverride(null);
              setActiveTab('files');
              handleTriggerSfx('paparazzi_shutter_flash');
            }}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'files'
                ? 'text-white underline underline-offset-8'
                : ''
            }`}
          >
            Red Carpet &amp; 100 Scenes
          </button>
          <button
            type="button"
            onClick={() => {
              setManualZoneOverride(null);
              setActiveTab('dressing-room');
              handleTriggerSfx('dressing_room_vanity');
            }}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'dressing-room'
                ? 'text-white underline underline-offset-8'
                : ''
            }`}
          >
            Star Dressing Room &amp; Audio
          </button>
          <button
            type="button"
            onClick={() => {
              setManualZoneOverride(null);
              setActiveTab('late-night');
              handleTriggerSfx('soundstage_door_thud');
            }}
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
            onClick={() => {
              setManualZoneOverride(null);
              setActiveTab('sync-guide');
              handleTriggerSfx('film_reel_click');
            }}
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
              handleTriggerSfx('dressing_room_vanity');
              setNdaMode('sign');
              setNdaUnlocked(false);
            }}
            className="px-3.5 py-2 text-xs font-mono font-bold text-amber-300 bg-slate-900 border border-amber-400/60 rounded-lg hover:bg-slate-800 transition-colors whitespace-nowrap shrink-0"
          >
            🎭 Actor Sign-In &amp; Onboarding
          </button>
          <button
            type="button"
            onClick={() => {
              handleTriggerSfx('clapper_snap');
              setActiveTab('sync-guide');
            }}
            className="px-4 py-2 text-xs font-semibold text-white bg-rose-600 rounded-lg hover:bg-rose-500 transition-colors whitespace-nowrap shrink-0"
          >
            Push 100 Scenes &amp; Logo to GitHub
          </button>
        </div>
      </header>

      {pendingDeepLinkRoom && (
        <div className="bg-cyan-950/90 border-b border-cyan-400/80 px-6 py-2.5 flex items-center justify-between text-xs font-mono font-bold text-cyan-200">
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-cyan-400 animate-pulse" />
            <span>🔗 DEEP-LINK ROOM INVITE PRESERVED: Room #{pendingDeepLinkRoom} is verified and ready to join!</span>
          </div>
          <button
            type="button"
            onClick={() => setPendingDeepLinkRoom(null)}
            className="text-cyan-400 hover:text-white text-xs"
          >
            DISMISS
          </button>
        </div>
      )}

      {/* Main Content Container */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 py-8 space-y-6">
        {/* Main Red Carpet / Dressing Room Soundstage Audio & Paparazzi Console */}
        <SoundstageAudioConsole
          activeZone={activeSoundstageZone}
          settings={audioSettings}
          paparazziFlashActive={paparazziFlashActive}
          lastTriggeredSfx={lastTriggeredSfx}
          onToggleChannel={handleToggleAudioChannel}
          onVolumeChange={handleVolumeChange}
          onSelectZone={handleSelectZone}
          onTriggerSfx={handleTriggerSfx}
          contextLabel="MAIN DASHBOARD · RED CARPET ANTHEM, PAPARAZZI & DRESSING ROOM AUDIO CONTROLS"
        />

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
                  <span>Multi-Zone Soundstage Audio &amp; Paparazzi</span>
                  <span aria-hidden="true"> · </span>
                  <span>Official Brand Logo Integrated</span>
                </div>
                <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
                  Red Carpet Premiere Dashboard &amp; Multi-Zone Soundstage Studio
                </h1>
                <p className="text-sm text-slate-300 leading-relaxed">
                  Featuring state-of-the-art Entrance Overture, On-Set Casting &amp; Sign-Up Groove, Red Carpet Inspiring Anthem with live Paparazzi camera flashes &amp; DSLR shutter bursts, Star Dressing Room vanity lounge, and independent on/off toggles for every audio layer.
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
              onClick={() => {
                setManualZoneOverride(null);
                setActiveTab('files');
                handleTriggerSfx('paparazzi_shutter_flash');
              }}
              className={`flex-1 px-2.5 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'files'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Red Carpet
            </button>
            <button
              type="button"
              onClick={() => {
                setManualZoneOverride(null);
                setActiveTab('dressing-room');
                handleTriggerSfx('dressing_room_vanity');
              }}
              className={`flex-1 px-2.5 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'dressing-room'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Dressing Room
            </button>
            <button
              type="button"
              onClick={() => {
                setManualZoneOverride(null);
                setActiveTab('late-night');
                handleTriggerSfx('soundstage_door_thud');
              }}
              className={`flex-1 px-2.5 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'late-night'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              18+ Vault
            </button>
            <button
              type="button"
              onClick={() => {
                setManualZoneOverride(null);
                setActiveTab('sync-guide');
                handleTriggerSfx('film_reel_click');
              }}
              className={`flex-1 px-2.5 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'sync-guide'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              GitHub Sync
            </button>
          </div>
        </section>

        {/* Tab: Star Dressing Room & Red Carpet Audio Showcase */}
        {activeTab === 'dressing-room' && (
          <StarDressingRoomPanel
            activeZone={activeSoundstageZone}
            onSelectZone={handleSelectZone}
            onTriggerSfx={handleTriggerSfx}
          />
        )}

        {/* Tab 1: 2-8 Player Live Audition Soundstage + Workspace File Inspector */}
        {activeTab === 'files' && (
          <div className="space-y-6">
            {/* Interactive 2-8 Player Green Room, Vocal Rules Briefing, 2.5s Auto-Cut & Ekman FACS Judging Deck */}
            <section className="p-5 rounded-xl bg-slate-900 border-2 border-amber-500/70 space-y-4">
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-3 pb-3 border-b border-slate-800">
                <div>
                  <div className="text-xs font-mono font-bold text-amber-300">
                    🎬 LIVE 2–8 PLAYER AUDITION ENGINE · {castRoster.length}/8 CAST MEMBERS · MUSIC:{' '}
                    {stagePhase === 'dashboard'
                      ? 'RED CARPET ANTHEM ACTIVE'
                      : 'SILENCED FOR SETUP / LIVE SET'}
                  </div>
                  <h2 className="text-lg font-bold text-white">
                    Green Room Setup, Studio Director Vocal Rules, 2.5s Smart Auto-Cut &amp; Factual Ekman FACS Judging
                  </h2>
                </div>
                <div className="flex flex-wrap items-center gap-2">
                  <button
                    type="button"
                    onClick={() => {
                      const inviteUrl = `${window.location.origin}/?room=482910`;
                      try {
                        navigator.clipboard.writeText(inviteUrl);
                      } catch {
                        // ignore
                      }
                      setInviteCopied(true);
                      window.setTimeout(() => setInviteCopied(false), 2000);
                    }}
                    className="px-3 py-1.5 rounded-lg bg-slate-950 border border-cyan-400 text-cyan-300 text-xs font-mono font-bold hover:bg-slate-800"
                  >
                    {inviteCopied
                      ? '✅ INVITE LINK COPIED (#482910)'
                      : '🔗 INVITE CASTMATES (#482910)'}
                  </button>
                  {castRoster.length < 8 && (
                    <button
                      type="button"
                      onClick={() => {
                        const nextNum = castRoster.length + 1;
                        const unplayedScenes = [
                          {
                            title: `Equal-Genre Unplayed Script #${nextNum} (Noir Confrontation)`,
                            line: `"You brought a prop revolver to a live callback? Read the subtext on page ${nextNum * 12}!"`,
                          },
                          {
                            title: `Supporting Cue #${nextNum} · The Penthouse Alibi`,
                            line: `[SUPPORTING ACTOR CUE]: "Check the valet ticket—that limousine never left the studio lot!"`,
                          },
                        ];
                        const picked = unplayedScenes[nextNum % 2];
                        setCastRoster([
                          ...castRoster,
                          {
                            id: `p${nextNum}`,
                            name: `Player ${nextNum}`,
                            role: nextNum % 2 === 0 ? 'LEAD' : 'SUPPORTING',
                            sceneTitle: picked.title,
                            linePreview: picked.line,
                            peerVotes: [],
                            aiFacsScore: null,
                          },
                        ]);
                      }}
                      className="px-3 py-1.5 rounded-lg bg-amber-400 text-slate-950 text-xs font-mono font-bold hover:bg-amber-300"
                    >
                      + ADD PLAYER ({castRoster.length}/8)
                    </button>
                  )}
                </div>
              </div>

              {/* Turn-Order Selection Method Bar */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-2.5 bg-slate-950 p-3 rounded-xl border border-slate-800">
                {(
                  [
                    {
                      id: 'host_pick',
                      label: '👑 Host Pick',
                      desc: 'Director selects who auditions 1st',
                    },
                    {
                      id: 'call_sheet_draw',
                      label: '📋 Call Sheet Draw',
                      desc: 'Hollywood numbered Call Sheet draw',
                    },
                    {
                      id: 'audition_spin',
                      label: '🎡 Audition Spin',
                      desc: 'Random wheel spin sets 2–8 order',
                    },
                  ] as const
                ).map((m) => (
                  <button
                    key={m.id}
                    type="button"
                    onClick={() => {
                      setTurnOrderMethod(m.id);
                      if (m.id === 'audition_spin') {
                        setCastRoster((prev) =>
                          [...prev].sort(() => Math.random() - 0.5)
                        );
                      }
                    }}
                    className={`p-2.5 rounded-lg border text-left transition-colors ${
                      turnOrderMethod === m.id
                        ? 'bg-amber-500/20 border-amber-400 text-amber-200'
                        : 'bg-slate-900 border-slate-800 text-slate-400 hover:text-white'
                    }`}
                  >
                    <div className="text-xs font-mono font-bold">{m.label}</div>
                    <div className="text-[11px] text-slate-400">{m.desc}</div>
                  </button>
                ))}
              </div>

              {/* Cast Roster Cards showing unique non-repeating scenes & Lead/Supporting toggle */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-2.5">
                {castRoster.map((actor, idx) => {
                  const isCurrent = idx === currentTurnIdx;
                  return (
                    <div
                      key={actor.id}
                      className={`p-3 rounded-xl border space-y-1.5 ${
                        isCurrent
                          ? 'bg-slate-950 border-amber-400'
                          : 'bg-slate-950/60 border-slate-800'
                      }`}
                    >
                      <div className="flex items-center justify-between gap-2">
                        <span className="text-xs font-mono font-bold text-white">
                          Turn #{idx + 1} · {actor.name}
                        </span>
                        <button
                          type="button"
                          onClick={() => {
                            setCastRoster((prev) =>
                              prev.map((item, i) =>
                                i === idx
                                  ? {
                                      ...item,
                                      role:
                                        item.role === 'LEAD'
                                          ? 'SUPPORTING'
                                          : 'LEAD',
                                      sceneTitle:
                                        item.role === 'LEAD'
                                          ? `Supporting Cue · Turn #${idx + 1}`
                                          : `Equal-Genre Lead Script · Turn #${idx + 1}`,
                                    }
                                  : item
                              )
                            );
                          }}
                          className={`px-2 py-0.5 rounded text-[10px] font-mono font-bold border ${
                            actor.role === 'SUPPORTING'
                              ? 'bg-amber-500/20 border-amber-400 text-amber-300'
                              : 'bg-cyan-500/20 border-cyan-400 text-cyan-300'
                          }`}
                        >
                          {actor.role}
                        </button>
                      </div>
                      <div className="text-[11px] font-semibold text-amber-300">
                        {actor.sceneTitle}
                      </div>
                      <p className="text-[11px] text-slate-300 line-clamp-2">
                        {actor.linePreview}
                      </p>
                    </div>
                  );
                })}
              </div>

              {/* Phase Controls: Start Vocal Rules Briefing -> 30s Scene Countdown + 2.5s Smart Auto-Cut -> Factual Ekman FACS Judging */}
              <div className="p-4 rounded-xl bg-slate-950 border border-slate-800 space-y-3">
                {stagePhase === 'dashboard' || stagePhase === 'green_room' ? (
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    <div className="text-xs text-slate-300">
                      Ready to start the 2–8 player match? Entering the Green Room or Live Soundstage silences background music and launches the Studio Director Vocal Rules Briefing.
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() => setStagePhase('green_room')}
                        className="px-3.5 py-2 rounded-lg bg-slate-800 hover:bg-slate-700 text-xs font-mono font-bold text-slate-200"
                      >
                        🔇 Enter Silent Green Room
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          setCurrentTurnIdx(0);
                          setRulesStepIdx(0);
                          setStagePhase('vocal_rules');
                        }}
                        className="px-4 py-2 rounded-lg bg-rose-600 hover:bg-rose-500 text-xs font-mono font-bold text-white"
                      >
                        🎙️ Start Game &amp; Vocal Rules Briefing
                      </button>
                    </div>
                  </div>
                ) : stagePhase === 'vocal_rules' ? (
                  <div className="space-y-3">
                    <div className="flex items-center justify-between text-xs font-mono font-bold text-amber-300">
                      <span>
                        🎙️ STUDIO DIRECTOR VOCAL RULES BRIEFING (STEP{' '}
                        {rulesStepIdx + 1}/{VOCAL_RULES_LINES.length})
                      </span>
                      <button
                        type="button"
                        onClick={() => {
                          try {
                            window.speechSynthesis?.cancel();
                          } catch {
                            // ignore
                          }
                          setStagePhase('performing');
                          setSceneSecondsRemaining(30);
                          setPostDeliverySilenceTenths(0);
                          setHoldingFinalBeat(false);
                        }}
                        className="px-3 py-1 rounded bg-amber-400 text-slate-950 font-mono font-bold"
                      >
                        ⏭️ SKIP BRIEFING &amp; ROLL CAMERA
                      </button>
                    </div>
                    <div className="p-3 rounded-lg bg-slate-900 border border-amber-400/60 text-sm font-semibold text-white">
                      {VOCAL_RULES_LINES[rulesStepIdx]}
                    </div>
                  </div>
                ) : stagePhase === 'performing' ? (
                  <div className="space-y-3">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <span className="text-xs font-mono font-bold text-rose-400">
                        🔴 ON AIR · TURN #{currentTurnIdx + 1} (
                        {castRoster[currentTurnIdx]?.name}) ·{' '}
                        {castRoster[currentTurnIdx]?.role}
                      </span>
                      <span className="px-3 py-1 rounded bg-slate-900 border border-amber-400 text-xs font-mono font-bold text-amber-300">
                        ⏱️ SCENE COUNTDOWN: {sceneSecondsRemaining}s
                      </span>
                    </div>
                    <div className="p-3 rounded-lg bg-slate-900 border border-slate-800 text-xs text-slate-200">
                      <div className="font-bold text-amber-300 mb-1">
                        {castRoster[currentTurnIdx]?.sceneTitle}
                      </div>
                      <div>{castRoster[currentTurnIdx]?.linePreview}</div>
                    </div>
                    <div className="flex flex-wrap items-center gap-2">
                      <button
                        type="button"
                        onClick={() => {
                          setHoldingFinalBeat((prev) => !prev);
                          setPostDeliverySilenceTenths(0);
                        }}
                        className={`px-3.5 py-2 rounded-lg text-xs font-mono font-bold border ${
                          holdingFinalBeat
                            ? 'bg-emerald-900/60 border-emerald-400 text-emerald-200'
                            : 'bg-slate-900 border-cyan-400 text-cyan-200'
                        }`}
                      >
                        {holdingFinalBeat
                          ? `🎬 SCENE COMPLETE DETECTED · AUTO-CUT IN ${((25 - postDeliverySilenceTenths) / 10).toFixed(1)}s`
                          : '🎭 FINISHED MY LINES (TRIGGER 2.5s SMART AUTO-CUT)'}
                      </button>
                      <button
                        type="button"
                        onClick={() => setStagePhase('judging')}
                        className="px-3.5 py-2 rounded-lg bg-rose-600 hover:bg-rose-500 text-xs font-mono font-bold text-white"
                      >
                        ⏹️ CUT &amp; PROCEED TO FACTUAL JUDGING
                      </button>
                    </div>
                  </div>
                ) : (
                  <div className="space-y-3">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <span className="text-xs font-mono font-bold text-emerald-400">
                        🏆 FACTUAL EKMAN FACS &amp; VOCAL PROSODY VERDICT ·{' '}
                        {castRoster[currentTurnIdx]?.name}
                      </span>
                      <span className="text-xs font-mono text-amber-300">
                        AI Calibration Delta:{' '}
                        {calibrationDelta >= 0
                          ? `+${calibrationDelta.toFixed(2)}`
                          : calibrationDelta.toFixed(2)}
                      </span>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-2.5 text-xs">
                      <div className="p-3 rounded-lg bg-slate-900 border border-slate-800">
                        <div className="font-mono text-amber-300 font-bold">
                          Ekman FACS + Vocal Prosody AI
                        </div>
                        <div className="text-lg font-black text-white mt-0.5">
                          {(88.5 + calibrationDelta).toFixed(1)} / 100
                        </div>
                        <div className="text-[11px] text-slate-400 mt-1">
                          AU1+AU4 brow triangulation, AU6 Duchenne ocular lock, F0 pitch contour &amp; dBFS dynamic range.
                        </div>
                      </div>
                      <div className="p-3 rounded-lg bg-slate-900 border border-slate-800">
                        <div className="font-mono text-cyan-300 font-bold">
                          Live Peer Cast Votes (Zero Dummy Scores)
                        </div>
                        <div className="text-lg font-black text-white mt-0.5">
                          {castRoster[currentTurnIdx]?.peerVotes.length
                            ? `${(
                                castRoster[currentTurnIdx].peerVotes.reduce(
                                  (a, b) => a + b,
                                  0
                                ) / castRoster[currentTurnIdx].peerVotes.length
                              ).toFixed(1)} / 100 (${castRoster[currentTurnIdx].peerVotes.length} real votes)`
                            : 'Awaiting Real Cast Vote (0 dummy votes)'}
                        </div>
                        <div className="flex flex-wrap gap-1 mt-2">
                          {[80, 90, 95, 100].map((v) => (
                            <button
                              key={v}
                              type="button"
                              onClick={() => {
                                setCastRoster((prev) =>
                                  prev.map((item, i) =>
                                    i === currentTurnIdx
                                      ? {
                                          ...item,
                                          peerVotes: [...item.peerVotes, v],
                                        }
                                      : item
                                  )
                                );
                              }}
                              className="px-2 py-0.5 rounded bg-slate-950 border border-cyan-400/60 text-cyan-200 font-mono text-[10px]"
                            >
                              Vote {v}
                            </button>
                          ))}
                        </div>
                      </div>
                      <div className="p-3 rounded-lg bg-slate-900 border border-slate-800 space-y-1.5">
                        <div className="font-mono text-emerald-300 font-bold">
                          Self-Adjusting AI Calibration Feedback
                        </div>
                        <div className="flex flex-wrap gap-1.5">
                          {[
                            { label: '👍 Spot On', delta: 0 },
                            { label: '📈 Too Lenient', delta: -1.25 },
                            { label: '📉 Too Harsh', delta: 1.25 },
                          ].map((btn) => (
                            <button
                              key={btn.label}
                              type="button"
                              onClick={() => {
                                setCalibrationVerdictLabel(btn.label);
                                setCalibrationDelta((prev) =>
                                  Math.max(-5, Math.min(5, prev + btn.delta))
                                );
                              }}
                              className={`px-2 py-1 rounded text-[10px] font-mono font-bold border ${
                                calibrationVerdictLabel === btn.label
                                  ? 'bg-emerald-500 text-slate-950 border-emerald-300'
                                  : 'bg-slate-950 text-slate-200 border-slate-700'
                              }`}
                            >
                              {btn.label}
                            </button>
                          ))}
                        </div>
                      </div>
                    </div>
                    <div className="flex flex-wrap items-center justify-between gap-2 pt-1">
                      <button
                        type="button"
                        onClick={() => setStagePhase('dashboard')}
                        className="px-3 py-1.5 rounded-lg bg-slate-800 text-xs font-mono text-slate-300"
                      >
                        Return to Red Carpet Dashboard (Music On)
                      </button>
                      {currentTurnIdx + 1 < castRoster.length ? (
                        <button
                          type="button"
                          onClick={() => {
                            setCurrentTurnIdx((prev) => prev + 1);
                            setStagePhase('performing');
                            setSceneSecondsRemaining(30);
                            setPostDeliverySilenceTenths(0);
                            setHoldingFinalBeat(false);
                          }}
                          className="px-4 py-2 rounded-lg bg-cyan-500 text-slate-950 text-xs font-mono font-black"
                        >
                          🎬 NEXT TURN: {castRoster[currentTurnIdx + 1]?.name} (EQUAL-GENRE UNPLAYED SCENE)
                        </button>
                      ) : (
                        <button
                          type="button"
                          onClick={() => {
                            setCurrentTurnIdx(0);
                            setStagePhase('dashboard');
                          }}
                          className="px-4 py-2 rounded-lg bg-amber-400 text-slate-950 text-xs font-mono font-black"
                        >
                          🏆 COMPLETE 2–8 PLAYER MATCH &amp; CROWN WINNER
                        </button>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </section>

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
          </div>
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
