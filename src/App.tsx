import React, { useState } from 'react';
import {
  Copy,
  Check,
  FileCode2,
  Users,
  RefreshCw,
  Play,
  UserPlus,
} from 'lucide-react';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  getBatchCompletionRatio,
  isSixDigitLobbyCode,
} from './utils/part1Specs';

interface SimulatedPlayer {
  id: string;
  name: string;
  isHost: boolean;
  isReady: boolean;
}

const SCENE_SAMPLES: Record<
  string,
  { title: string; film: string; year: number; character: string; line: string; cue: string }
> = {
  'Eras: 1970–1999': {
    title: 'Tears in Rain',
    film: 'Blade Runner',
    year: 1982,
    character: 'Roy Batty',
    line: "I have seen things you people wouldn't believe. Attack ships on fire off the shoulder of Orion. All those moments will be lost in time, like tears in rain.",
    cue: 'Maintain steady eye contact with the lens and release a quiet breath on the final phrase.',
  },
  'Eras: 2000–2026': {
    title: 'Not Quite My Tempo',
    film: 'Whiplash',
    year: 2014,
    character: 'Terence Fletcher',
    line: 'Were you rushing or were you dragging? If you deliberately sabotage my band, I will gut you like a pig.',
    cue: 'Whisper the opening question with razor-sharp stillness, then snap into sudden percussive intensity.',
  },
  'Awards: Best Actor': {
    title: 'I Drink Your Milkshake',
    film: 'There Will Be Blood',
    year: 2007,
    character: 'Daniel Plainview',
    line: 'If you have a milkshake, and I have a milkshake, and I have a straw... my straw reaches across the room. I drink your milkshake!',
    cue: 'Lean forward into the frame and build rhythmic cadence.',
  },
  'Awards: Best Actress': {
    title: 'Dinner Table Monologue',
    film: 'Hereditary',
    year: 2018,
    character: 'Annie Graham',
    line: 'All I do is worry and slave and defend you, and all I get back is that face on your face!',
    cue: 'Hold trembling composure for two beats before letting raw grief overtake the line.',
  },
  'Awards: Best Villain': {
    title: 'Call It, Friendo',
    film: 'No Country for Old Men',
    year: 2007,
    character: 'Anton Chigurh',
    line: "What's the most you ever lost on a coin toss? Don't put it in your pocket. It's your lucky quarter.",
    cue: 'Zero blinking, flat deadpan cadence, chin tilted slightly down.',
  },
  'Awards: Emmy Vault': {
    title: 'I Am the One Who Knocks',
    film: 'Breaking Bad',
    year: 2011,
    character: 'Walter White',
    line: "You clearly don't know who you're talking to, so let me clue you in. I am not in danger, Skyler. I am the danger.",
    cue: 'Drop vocal pitch half an octave on the final five words.',
  },
  'Specialty: Cult Classics': {
    title: 'Coffee Is for Closers',
    film: 'Glengarry Glen Ross',
    year: 1992,
    character: 'Blake',
    line: "Coffee's for closers only. You think I'm messing with you? Always be closing.",
    cue: 'Snap fingers once and deliver with rapid-fire boardroom swagger.',
  },
};

export default function App() {
  const [selectedFilePath, setSelectedFilePath] = useState<string>('supabase/schema.sql');
  const [copiedPath, setCopiedPath] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'files' | 'lobby-sim' | 'sync-guide'>('files');

  // Interactive Part 2 Lobby Simulator State
  const [roomCode, setRoomCode] = useState<string>('482910');
  const [selectedCategory, setSelectedCategory] = useState<string>('Eras: 1970–1999');
  const [joinCodeInput, setJoinCodeInput] = useState<string>('');
  const [newPlayerName, setNewPlayerName] = useState<string>('');
  const [lobbyError, setLobbyError] = useState<string | null>(null);
  const [roundActive, setRoundActive] = useState<boolean>(false);
  const [players, setPlayers] = useState<SimulatedPlayer[]>([
    { id: 'p1', name: 'Galaxy S26 Host', isHost: true, isReady: true },
    { id: 'p2', name: 'Elena (Remote SFU #2)', isHost: false, isReady: true },
    { id: 'p3', name: 'Marcus (Remote SFU #3)', isHost: false, isReady: true },
  ]);

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

  const handleGenerateNewRoomCode = () => {
    const nextCode = String(100000 + Math.floor(Math.random() * 900000));
    setRoomCode(nextCode);
    setRoundActive(false);
    setLobbyError(null);
  };

  const handleAddRemotePlayer = (e: React.FormEvent) => {
    e.preventDefault();
    setLobbyError(null);
    const trimmedName = newPlayerName.trim();
    if (!trimmedName) {
      setLobbyError('Enter a stage display name to add a remote player.');
      return;
    }
    if (joinCodeInput.trim() && !isSixDigitLobbyCode(joinCodeInput)) {
      setLobbyError('Room code must be an exact 6-digit number.');
      return;
    }
    if (players.length >= 8) {
      setLobbyError('Lobby has reached the maximum capacity of 8 remote LiveKit SFU players.');
      return;
    }
    setPlayers((prev) => [
      ...prev,
      {
        id: `p-${Date.now()}`,
        name: trimmedName,
        isHost: false,
        isReady: true,
      },
    ]);
    setNewPlayerName('');
    setJoinCodeInput('');
  };

  const togglePlayerReady = (id: string) => {
    setPlayers((prev) =>
      prev.map((p) => (p.id === id ? { ...p, isReady: !p.isReady } : p))
    );
  };

  const activeScene = SCENE_SAMPLES[selectedCategory] ?? SCENE_SAMPLES['Eras: 1970–1999'];

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 font-['Plus_Jakarta_Sans',sans-serif] flex flex-col">
      {/* Top Bar Contract: 3 zones separated by gap-8 */}
      <header className="flex items-center justify-between gap-8 px-6 py-4 border-b border-slate-800 bg-slate-950">
        <a
          href="#top"
          className="text-lg font-bold tracking-tight text-white whitespace-nowrap shrink-0"
        >
          Act Like It
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
            Part 1 & 2 Files
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('lobby-sim')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'lobby-sim' ? 'text-white underline underline-offset-8' : ''
            }`}
          >
            6-Digit Lobby Simulator
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('sync-guide')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'sync-guide' ? 'text-white underline underline-offset-8' : ''
            }`}
          >
            GitHub Sync Protocol
          </button>
        </nav>

        <div className="flex items-center gap-3 shrink-0">
          <button
            type="button"
            onClick={() => setActiveTab('sync-guide')}
            className="px-4 py-2 text-xs font-semibold text-white bg-rose-600 rounded-lg hover:bg-rose-500 transition-colors whitespace-nowrap shrink-0"
          >
            Push Part 2 to GitHub
          </button>
        </div>
      </header>

      {/* Main Content Container */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 py-8 space-y-8">
        {/* Batch Status Banner */}
        <section className="p-6 rounded-xl bg-slate-900 border border-slate-800">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
            <div className="space-y-2 max-w-2xl">
              <div className="text-xs text-slate-400">
                <span>Samsung Galaxy S26 Ultra Cloud Workflow</span>
                <span aria-hidden="true"> · </span>
                <span>Zero Local Storage</span>
                <span aria-hidden="true"> · </span>
                <span>Batch 2 of 5 Ready</span>
              </div>
              <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
                Part 2: Database & Matchmaking Generated
              </h1>
              <p className="text-sm text-slate-300 leading-relaxed">
                Generated <code className="font-mono text-amber-400">supabase/schema.sql</code> (PostgreSQL tables & RLS for User Profiles, Eras 1970–1999 & 2000–2026, Awards Vault, Cult Classics, and 2–8 player Realtime Lobbies) and <code className="font-mono text-amber-400">lib/lobby.dart</code> (6-digit matchmaking & Supabase Realtime synchronization).
              </p>
            </div>

            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4 shrink-0">
              <div className="px-4 py-3 rounded-lg bg-slate-950 border border-slate-800 text-right">
                <div className="text-xs text-slate-400">Sequential Build Progress</div>
                <div className="text-xl font-bold font-mono tabular-nums text-white">
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
              Part 2 Files
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('lobby-sim')}
              className={`flex-1 px-3 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'lobby-sim'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              6-Digit Lobby
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
                  Generated Workspace Files
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
                  5-Part Execution Protocol
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
                        <span className="text-xs font-mono tabular-nums text-slate-400">
                          {stage.status === 'completed' ? 'Generated' : 'Queued'}
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

        {/* Tab 2: Interactive 6-Digit Lobby & Supabase Realtime Simulator */}
        {activeTab === 'lobby-sim' && (
          <section className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
            <div className="lg:col-span-5 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="space-y-1">
                <h2 className="text-lg font-bold text-white">
                  6-Digit Matchmaking & Realtime Controls
                </h2>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Mirrors <code className="font-mono text-amber-400">LobbyRealtimeManager</code> in{' '}
                  <code className="font-mono text-amber-400">lib/lobby.dart</code> and the PostgreSQL trigger enforcing 2–8 remote players.
                </p>
              </div>

              <div className="p-4 rounded-lg bg-slate-950 border border-slate-800 flex items-center justify-between gap-4">
                <div>
                  <div className="text-xs text-slate-400">Active 6-Digit Room Code</div>
                  <div className="text-2xl font-bold font-mono tabular-nums tracking-widest text-amber-400">
                    {roomCode}
                  </div>
                </div>
                <button
                  type="button"
                  onClick={handleGenerateNewRoomCode}
                  className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-semibold rounded-lg bg-slate-800 hover:bg-slate-700 text-white transition-colors whitespace-nowrap shrink-0"
                >
                  <RefreshCw className="w-3.5 h-3.5" />
                  <span>New 6-Digit Code</span>
                </button>
              </div>

              <div className="space-y-2">
                <label
                  htmlFor="category-select"
                  className="block text-xs font-semibold text-slate-300"
                >
                  Supabase Scene Category Table
                </label>
                <select
                  id="category-select"
                  value={selectedCategory}
                  onChange={(e) => {
                    setSelectedCategory(e.target.value);
                    setRoundActive(false);
                  }}
                  className="w-full px-3 py-2.5 text-xs rounded-lg bg-slate-950 border border-slate-800 text-white"
                >
                  {Object.keys(SCENE_SAMPLES).map((cat) => (
                    <option key={cat} value={cat}>
                      {cat}
                    </option>
                  ))}
                </select>
              </div>

              <form onSubmit={handleAddRemotePlayer} className="space-y-3 pt-2 border-t border-slate-800">
                <div className="text-xs font-semibold text-slate-300">
                  Simulate Remote Player Joining via 6-Digit Code ({players.length}/8 Slots)
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label htmlFor="player-name-input" className="sr-only">
                      Remote Player Name
                    </label>
                    <input
                      id="player-name-input"
                      type="text"
                      value={newPlayerName}
                      onChange={(e) => setNewPlayerName(e.target.value)}
                      placeholder="Stage Name (e.g. Devon)"
                      className="w-full px-3 py-2 text-xs rounded-lg bg-slate-950 border border-slate-800 text-white"
                    />
                  </div>
                  <div>
                    <label htmlFor="join-code-input" className="sr-only">
                      6-Digit Room Code
                    </label>
                    <input
                      id="join-code-input"
                      type="text"
                      maxLength={6}
                      value={joinCodeInput}
                      onChange={(e) => setJoinCodeInput(e.target.value)}
                      placeholder={`Room Code (${roomCode})`}
                      className="w-full px-3 py-2 text-xs font-mono rounded-lg bg-slate-950 border border-slate-800 text-white"
                    />
                  </div>
                </div>
                {lobbyError && (
                  <p className="text-xs text-rose-400">{lobbyError}</p>
                )}
                <button
                  type="submit"
                  className="w-full inline-flex items-center justify-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-lg bg-slate-800 hover:bg-slate-700 text-white transition-colors whitespace-nowrap shrink-0"
                >
                  <UserPlus className="w-3.5 h-3.5" />
                  <span>Join Remote Player to Channel</span>
                </button>
              </form>
            </div>

            <div className="lg:col-span-7 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="flex items-center justify-between pb-3 border-b border-slate-800">
                <div>
                  <h3 className="text-base font-bold text-white">
                    Realtime Channel: <code className="font-mono text-amber-400">lobby:{roomCode}</code>
                  </h3>
                  <p className="text-xs text-slate-400">
                    LiveKit SFU Room: <code className="font-mono">act_like_it_{roomCode}</code> · {players.length} / 8 Remote Players
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setRoundActive(true)}
                  className="inline-flex items-center gap-1.5 px-4 py-2 text-xs font-semibold rounded-lg bg-rose-600 hover:bg-rose-500 text-white transition-colors whitespace-nowrap shrink-0"
                >
                  <Play className="w-3.5 h-3.5" />
                  <span>Draw Scene & Broadcast</span>
                </button>
              </div>

              {roundActive && (
                <div className="p-4 rounded-lg bg-slate-950 border border-rose-500 space-y-2">
                  <div className="text-xs font-mono text-amber-400">
                    BROADCAST EVENT: round_started · {selectedCategory} · {activeScene.film} ({activeScene.year})
                  </div>
                  <div className="text-sm font-semibold text-white">
                    {activeScene.character}: &ldquo;{activeScene.line}&rdquo;
                  </div>
                  <div className="text-xs text-slate-400">
                    Director Cue: {activeScene.cue}
                  </div>
                </div>
              )}

              <div className="space-y-2">
                {players.map((p) => (
                  <div
                    key={p.id}
                    className="p-3 rounded-lg bg-slate-950 border border-slate-800 flex items-center justify-between gap-4"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <Users className="w-4 h-4 text-slate-400 shrink-0" />
                      <div className="min-w-0">
                        <div className="text-xs font-semibold text-white truncate">
                          {p.name}
                        </div>
                        <div className="text-xs text-slate-400">
                          {p.isHost ? 'Lobby Host' : 'Remote SFU Performer / Spectator'}
                        </div>
                      </div>
                    </div>
                    <button
                      type="button"
                      onClick={() => togglePlayerReady(p.id)}
                      className={`px-3 py-1 text-xs font-mono font-semibold rounded transition-colors whitespace-nowrap shrink-0 ${
                        p.isReady
                          ? 'bg-emerald-950 text-emerald-300 border border-emerald-800'
                          : 'bg-amber-950 text-amber-300 border border-amber-800'
                      }`}
                    >
                      {p.isReady ? 'READY' : 'WAITING'}
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </section>
        )}

        {/* Tab 3: GitHub Sync Guide for Part 2 */}
        {activeTab === 'sync-guide' && (
          <section className="p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-6">
            <div className="space-y-2">
              <h2 className="text-xl font-bold text-white">
                Push Part 2 Changes to GitHub (act_like_it)
              </h2>
              <p className="text-sm text-slate-300">
                Commit and push the newly generated database schema and matchmaking synchronization files directly from AI Studio:
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">01. Open GitHub Tab</div>
                <h3 className="text-base font-semibold text-white">
                  Verify Staged Part 2 Files
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Confirm that <code className="font-mono text-white">supabase/schema.sql</code>, <code className="font-mono text-white">lib/lobby.dart</code>, and the updated <code className="font-mono text-white">lib/main.dart</code> appear in your GitHub sync list.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">02. Sync to GitHub</div>
                <h3 className="text-base font-semibold text-white">
                  Tap &ldquo;Push Changes&rdquo;
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Push the commit directly to your private <code className="font-mono text-white">act_like_it</code> repository from your Galaxy S26 Ultra browser.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">03. Advance to Part 3</div>
                <h3 className="text-base font-semibold text-white">
                  Confirm Completion
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Once pushed, instruct me to proceed to Part 3 (<code className="font-mono text-white">lib/webrtc_manager.dart</code> for LiveKit WebRTC camera capture and SFU broadcast routing).
                </p>
              </div>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}
