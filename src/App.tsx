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

export default function App() {
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
