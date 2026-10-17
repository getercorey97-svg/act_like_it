import React, { useState } from 'react';
import {
  Copy,
  Check,
  FileCode2,
  Video,
  VideoOff,
  Mic,
  MicOff,
  Camera,
  Radio,
  Users,
} from 'lucide-react';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  getBatchCompletionRatio,
  calculateSfuBandwidthSavings,
} from './utils/part1Specs';

export default function App() {
  const [selectedFilePath, setSelectedFilePath] = useState<string>('lib/webrtc_manager.dart');
  const [copiedPath, setCopiedPath] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'files' | 'sfu-stage' | 'sync-guide'>('files');

  // Part 3 LiveKit WebRTC SFU Stage Simulator State
  const [sfuRole, setSfuRole] = useState<'activePerformer' | 'remoteSpectator'>('activePerformer');
  const [playerCount, setPlayerCount] = useState<number>(6);
  const [camEnabled, setCamEnabled] = useState<boolean>(true);
  const [micEnabled, setMicEnabled] = useState<boolean>(true);
  const [cameraLens, setCameraLens] = useState<'Front (Selfie 720p30)' | 'Rear (Telephoto)'>('Front (Selfie 720p30)');
  const [sampledFrames, setSampledFrames] = useState<number>(14);

  const selectedFile =
    WORKSPACE_FILES.find((f) => f.path === selectedFilePath) ?? WORKSPACE_FILES[0];
  const progress = getBatchCompletionRatio(BATCH_STAGES);
  const sfuMetrics = calculateSfuBandwidthSavings(playerCount, sfuRole);

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
            Part 1–3 Files
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('sfu-stage')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'sfu-stage' ? 'text-white underline underline-offset-8' : ''
            }`}
          >
            LiveKit SFU Stage Simulator
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
            Push Part 3 to GitHub
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
                <span>Batch 3 of 5 Ready</span>
              </div>
              <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
                Part 3: Real-Time Media Routing Generated
              </h1>
              <p className="text-sm text-slate-300 leading-relaxed">
                Generated <code className="font-mono text-amber-400">lib/webrtc_manager.dart</code> with LiveKit WebRTC camera capture, <code className="font-mono text-amber-400">adaptiveStream</code> + <code className="font-mono text-amber-400">dynacast</code> + <code className="font-mono text-amber-400">simulcast</code> SFU routing for 2–8 remote players, and 1 Hz telemetrics frame sampling for Part 4.
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
              Part 3 Files
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('sfu-stage')}
              className={`flex-1 px-3 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'sfu-stage'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              LiveKit SFU
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

        {/* Tab 2: LiveKit WebRTC SFU Stage Simulator */}
        {activeTab === 'sfu-stage' && (
          <section className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
            {/* Left Column: SFU Bandwidth & Role Configuration */}
            <div className="lg:col-span-5 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="space-y-1">
                <h2 className="text-lg font-bold text-white">
                  LiveKit SFU Mesh & Dynacast Controls
                </h2>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Simulates <code className="font-mono text-amber-400">WebRtcStageManager</code> in{' '}
                  <code className="font-mono text-amber-400">lib/webrtc_manager.dart</code> across 2–8 remote players.
                </p>
              </div>

              <div className="space-y-2">
                <span className="block text-xs font-semibold text-slate-300">
                  Local Participant Role
                </span>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => {
                      setSfuRole('activePerformer');
                      setCamEnabled(true);
                      setMicEnabled(true);
                    }}
                    className={`px-3 py-2.5 text-xs font-semibold rounded-lg border transition-colors whitespace-nowrap shrink-0 ${
                      sfuRole === 'activePerformer'
                        ? 'bg-rose-600 border-rose-500 text-white'
                        : 'bg-slate-950 border-slate-800 text-slate-300'
                    }`}
                  >
                    Active Performer
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setSfuRole('remoteSpectator');
                      setCamEnabled(false);
                      setMicEnabled(false);
                    }}
                    className={`px-3 py-2.5 text-xs font-semibold rounded-lg border transition-colors whitespace-nowrap shrink-0 ${
                      sfuRole === 'remoteSpectator'
                        ? 'bg-rose-600 border-rose-500 text-white'
                        : 'bg-slate-950 border-slate-800 text-slate-300'
                    }`}
                  >
                    Remote Spectator
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <label
                  htmlFor="player-count-range"
                  className="flex items-center justify-between gap-2 text-xs font-semibold text-slate-300"
                >
                  <span className="truncate">Remote SFU Slots (2–8)</span>
                  <span className="font-mono tabular-nums text-amber-400 whitespace-nowrap shrink-0">
                    {playerCount} Players
                  </span>
                </label>
                <input
                  id="player-count-range"
                  type="range"
                  min={2}
                  max={8}
                  value={playerCount}
                  onChange={(e) => setPlayerCount(Number(e.target.value))}
                  className="w-full accent-rose-600"
                />
              </div>

              <div className="p-4 rounded-lg bg-slate-950 border border-slate-800 space-y-2 text-xs">
                <div className="flex items-center justify-between">
                  <span className="text-slate-400">SFU Upstream Bitrate:</span>
                  <span className="font-mono tabular-nums font-semibold text-emerald-400">
                    {sfuMetrics.sfuUpstreamKbps} kbps
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-slate-400">Legacy P2P Mesh Upstream:</span>
                  <span className="font-mono tabular-nums text-slate-400">
                    {sfuMetrics.p2pUpstreamKbps} kbps
                  </span>
                </div>
                <div className="flex items-center justify-between pt-1 border-t border-slate-800">
                  <span className="text-slate-300 font-semibold">Mobile Bandwidth Saved:</span>
                  <span className="font-mono tabular-nums font-bold text-amber-400">
                    {sfuMetrics.bandwidthSavedPercent}% Reduction
                  </span>
                </div>
              </div>
            </div>

            {/* Right Column: LiveKitSoundstageScreen Viewport */}
            <div className="lg:col-span-7 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="flex items-center justify-between pb-3 border-b border-slate-800">
                <div>
                  <h3 className="text-base font-bold text-white">
                    LiveKitSoundstageScreen · Room #482910
                  </h3>
                  <p className="text-xs text-slate-400">
                    Lens: {cameraLens} · Telemetrics Buffer: {sampledFrames} Samples (1 Hz)
                  </p>
                </div>
                <span className="font-mono text-xs font-semibold text-rose-400">
                  {sfuRole === 'activePerformer' ? 'ON AIR · 720p30 SFU' : 'SPECTATING · DYNACAST'}
                </span>
              </div>

              <div className="p-6 rounded-xl bg-slate-950 border border-slate-800 space-y-4">
                <div className="flex items-center justify-between text-xs text-slate-400">
                  <span>VideoTrackRenderer (RTCVideoViewObjectFitCover)</span>
                  <span className="font-mono tabular-nums text-amber-400">
                    Audio: {micEnabled ? '-14.5 dBFS' : 'Muted (-60 dBFS)'}
                  </span>
                </div>

                <div className="p-4 rounded-lg bg-slate-900 border border-slate-800 space-y-1.5">
                  <div className="text-xs font-semibold text-amber-400">
                    Roy Batty · Blade Runner (1982)
                  </div>
                  <p className="text-sm font-bold text-white">
                    &ldquo;I have seen things you people wouldn&apos;t believe. Attack ships on fire off the shoulder of Orion. All those moments will be lost in time, like tears in rain.&rdquo;
                  </p>
                  <p className="text-xs text-slate-400">
                    Cue: Begin with quiet awe · Target Emotion: Melancholic Transcendence
                  </p>
                </div>

                <div className="flex flex-wrap items-center gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setCamEnabled((v) => !v)}
                    className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-semibold rounded-lg bg-slate-800 hover:bg-slate-700 text-white transition-colors whitespace-nowrap shrink-0"
                  >
                    {camEnabled ? <Video className="w-3.5 h-3.5" /> : <VideoOff className="w-3.5 h-3.5" />}
                    <span>{camEnabled ? 'Cam On' : 'Cam Off'}</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setMicEnabled((v) => !v)}
                    className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-semibold rounded-lg bg-slate-800 hover:bg-slate-700 text-white transition-colors whitespace-nowrap shrink-0"
                  >
                    {micEnabled ? <Mic className="w-3.5 h-3.5" /> : <MicOff className="w-3.5 h-3.5" />}
                    <span>{micEnabled ? 'Mic On' : 'Mic Off'}</span>
                  </button>
                  <button
                    type="button"
                    onClick={() =>
                      setCameraLens((prev) =>
                        prev === 'Front (Selfie 720p30)'
                          ? 'Rear (Telephoto)'
                          : 'Front (Selfie 720p30)'
                      )
                    }
                    className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-semibold rounded-lg bg-slate-800 hover:bg-slate-700 text-white transition-colors whitespace-nowrap shrink-0"
                  >
                    <Camera className="w-3.5 h-3.5" />
                    <span>Flip Galaxy S26 Lens</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setSampledFrames((n) => n + 1)}
                    className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-semibold rounded-lg bg-rose-600 hover:bg-rose-500 text-white transition-colors whitespace-nowrap shrink-0"
                  >
                    <Radio className="w-3.5 h-3.5" />
                    <span>Sample 1 Hz Telemetry Frame</span>
                  </button>
                </div>
              </div>
            </div>
          </section>
        )}

        {/* Tab 3: GitHub Sync Guide for Part 3 */}
        {activeTab === 'sync-guide' && (
          <section className="p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-6">
            <div className="space-y-2">
              <h2 className="text-xl font-bold text-white">
                Push Part 3 Changes to GitHub (act_like_it)
              </h2>
              <p className="text-sm text-slate-300">
                Push the LiveKit WebRTC camera capture and SFU broadcast module directly from Google AI Studio to your remote GitHub repository:
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">01. Open GitHub Tab</div>
                <h3 className="text-base font-semibold text-white">
                  Verify Staged Part 3 Files
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Verify that <code className="font-mono text-white">lib/webrtc_manager.dart</code> and the updated <code className="font-mono text-white">lib/lobby.dart</code> are staged in the GitHub panel.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">02. Sync to GitHub</div>
                <h3 className="text-base font-semibold text-white">
                  Tap &ldquo;Push Changes&rdquo;
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Commit and push Part 3 directly from your Samsung Galaxy S26 Ultra browser with zero local storage.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">03. Advance to Part 4</div>
                <h3 className="text-base font-semibold text-white">
                  Confirm Completion
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Once pushed, instruct me to proceed to Part 4 (<code className="font-mono text-white">lib/judging_engine.dart</code> for Gemini AI Telemetrics and Supabase Storage looped video playback).
                </p>
              </div>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}
