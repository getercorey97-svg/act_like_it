import React, { useState } from 'react';
import {
  Copy,
  Check,
  FileCode2,
  Repeat,
  Share2,
  Sparkles,
  Users,
} from 'lucide-react';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  getBatchCompletionRatio,
  calculateTriModalCompositeScore,
} from './utils/part1Specs';

export default function App() {
  const [selectedFilePath, setSelectedFilePath] = useState<string>('lib/judging_engine.dart');
  const [copiedPath, setCopiedPath] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'files' | 'judging-sim' | 'sync-guide'>('files');

  // Part 4 Tri-Modal Judging & Supabase Loop Simulator State
  const [facialScore, setFacialScore] = useState<number>(91);
  const [vocalScore, setVocalScore] = useState<number>(88);
  const [cueFidelity, setCueFidelity] = useState<number>(94);
  const [peerVoteScore, setPeerVoteScore] = useState<number>(89);
  const [externalShares, setExternalShares] = useState<number>(3);
  const [externalReactions, setExternalReactions] = useState<number>(8);
  const [loopCompletions, setLoopCompletions] = useState<number>(12);

  const selectedFile =
    WORKSPACE_FILES.find((f) => f.path === selectedFilePath) ?? WORKSPACE_FILES[0];
  const progress = getBatchCompletionRatio(BATCH_STAGES);

  const triModal = calculateTriModalCompositeScore({
    facialExpression: facialScore,
    vocalCadence: vocalScore,
    directorCueFidelity: cueFidelity,
    peerVoteScore,
    externalShares,
    externalReactions,
    loopCompletions,
  });

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
            Part 1–4 Files
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('judging-sim')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'judging-sim' ? 'text-white underline underline-offset-8' : ''
            }`}
          >
            Tri-Modal Judging Simulator
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
            Push Part 4 to GitHub
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
                <span>Batch 4 of 5 Ready</span>
              </div>
              <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
                Part 4: AI Telemetrics & UI Looping Generated
              </h1>
              <p className="text-sm text-slate-300 leading-relaxed">
                Generated <code className="font-mono text-amber-400">lib/judging_engine.dart</code> integrating Google Gemini (<code className="font-mono text-amber-400">gemini-2.5-flash</code>) multimodal frame/audio telemetrics judging, Supabase Edge Storage looped video playback (<code className="font-mono text-amber-400">performance-loops</code> bucket with <code className="font-mono text-amber-400">setLooping(true)</code>), and Social Share metric calculation.
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
              Part 4 Files
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('judging-sim')}
              className={`flex-1 px-3 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'judging-sim'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Tri-Modal Judge
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

        {/* Tab 2: Tri-Modal Judging & Supabase Video Loop Simulator */}
        {activeTab === 'judging-sim' && (
          <section className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
            {/* Left Column: Tri-Modal Inputs */}
            <div className="lg:col-span-5 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="space-y-1">
                <h2 className="text-lg font-bold text-white">
                  Tri-Modal Judging Parameters
                </h2>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Simulates <code className="font-mono text-amber-400">TriModalJudgingEngine</code> in{' '}
                  <code className="font-mono text-amber-400">lib/judging_engine.dart</code> (45% AI Telemetrics · 35% Peer Loop · 20% Social Share).
                </p>
              </div>

              <div className="space-y-3">
                <div>
                  <label
                    htmlFor="facial-range"
                    className="flex items-center justify-between gap-2 text-xs font-semibold text-slate-300"
                  >
                    <span className="truncate">Gemini Facial Micro-Expression</span>
                    <span className="font-mono tabular-nums text-rose-400 whitespace-nowrap shrink-0">
                      {facialScore}/100
                    </span>
                  </label>
                  <input
                    id="facial-range"
                    type="range"
                    min={0}
                    max={100}
                    value={facialScore}
                    onChange={(e) => setFacialScore(Number(e.target.value))}
                    className="w-full accent-rose-600"
                  />
                </div>

                <div>
                  <label
                    htmlFor="vocal-range"
                    className="flex items-center justify-between gap-2 text-xs font-semibold text-slate-300"
                  >
                    <span className="truncate">Gemini Vocal Cadence & dBFS</span>
                    <span className="font-mono tabular-nums text-rose-400 whitespace-nowrap shrink-0">
                      {vocalScore}/100
                    </span>
                  </label>
                  <input
                    id="vocal-range"
                    type="range"
                    min={0}
                    max={100}
                    value={vocalScore}
                    onChange={(e) => setVocalScore(Number(e.target.value))}
                    className="w-full accent-rose-600"
                  />
                </div>

                <div>
                  <label
                    htmlFor="peer-range"
                    className="flex items-center justify-between gap-2 text-xs font-semibold text-slate-300"
                  >
                    <span className="truncate">Remote Peer Loop Score</span>
                    <span className="font-mono tabular-nums text-emerald-400 whitespace-nowrap shrink-0">
                      {peerVoteScore}/100
                    </span>
                  </label>
                  <input
                    id="peer-range"
                    type="range"
                    min={0}
                    max={100}
                    value={peerVoteScore}
                    onChange={(e) => setPeerVoteScore(Number(e.target.value))}
                    className="w-full accent-emerald-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setLoopCompletions((c) => c + 1)}
                  className="inline-flex items-center justify-center gap-1.5 px-3 py-2 text-xs font-semibold rounded-lg bg-slate-800 hover:bg-slate-700 text-white transition-colors whitespace-nowrap shrink-0"
                >
                  <Repeat className="w-3.5 h-3.5" />
                  <span>+1 Loop Replay ({loopCompletions})</span>
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setExternalShares((s) => s + 1);
                    setExternalReactions((r) => r + 4);
                  }}
                  className="inline-flex items-center justify-center gap-1.5 px-3 py-2 text-xs font-semibold rounded-lg bg-rose-600 hover:bg-rose-500 text-white transition-colors whitespace-nowrap shrink-0"
                >
                  <Share2 className="w-3.5 h-3.5" />
                  <span>Share Clip ({externalShares})</span>
                </button>
              </div>
            </div>

            {/* Right Column: TriModalJudgingScreen Output */}
            <div className="lg:col-span-7 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="flex items-center justify-between pb-3 border-b border-slate-800">
                <div>
                  <h3 className="text-base font-bold text-white">
                    TriModalJudgingScreen · Composite Result
                  </h3>
                  <p className="text-xs text-slate-400">
                    Bucket: <code className="font-mono">performance-loops/482910/actor_round_1.mp4</code>
                  </p>
                </div>
                <div className="text-right">
                  <div className="text-xs text-slate-400">Composite Score</div>
                  <div className="text-2xl font-bold font-mono tabular-nums text-amber-400">
                    {triModal.compositeScore} / 100
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="p-4 rounded-lg bg-slate-950 border border-slate-800 space-y-1">
                  <div className="flex items-center justify-between text-xs text-slate-400">
                    <span>1. AI Telemetrics</span>
                    <Sparkles className="w-3.5 h-3.5 text-rose-400" />
                  </div>
                  <div className="text-xl font-bold font-mono tabular-nums text-white">
                    {triModal.aiScore}
                  </div>
                  <div className="text-xs text-slate-400">45% Weight · Gemini 2.5</div>
                </div>

                <div className="p-4 rounded-lg bg-slate-950 border border-slate-800 space-y-1">
                  <div className="flex items-center justify-between text-xs text-slate-400">
                    <span>2. Peer Loop Vote</span>
                    <Users className="w-3.5 h-3.5 text-emerald-400" />
                  </div>
                  <div className="text-xl font-bold font-mono tabular-nums text-white">
                    {triModal.peerScore}
                  </div>
                  <div className="text-xs text-slate-400">35% Weight · Auto-Loop</div>
                </div>

                <div className="p-4 rounded-lg bg-slate-950 border border-slate-800 space-y-1">
                  <div className="flex items-center justify-between text-xs text-slate-400">
                    <span>3. Social Judging</span>
                    <Share2 className="w-3.5 h-3.5 text-amber-400" />
                  </div>
                  <div className="text-xl font-bold font-mono tabular-nums text-white">
                    {triModal.socialScore}
                  </div>
                  <div className="text-xs text-slate-400">20% Weight · Share API</div>
                </div>
              </div>

              <div className="p-4 rounded-lg bg-slate-950 border border-slate-800 space-y-1.5">
                <div className="text-xs font-mono text-emerald-400">
                  SUPABASE EDGE STORAGE · VideoPlayerController.setLooping(true)
                </div>
                <p className="text-xs text-slate-300 leading-relaxed">
                  Director Critique: &ldquo;Strong emotional commitment to Melancholic Transcendence with controlled vocal pacing across 14s of WebRTC telemetry.&rdquo;
                </p>
              </div>
            </div>
          </section>
        )}

        {/* Tab 3: GitHub Sync Guide for Part 4 */}
        {activeTab === 'sync-guide' && (
          <section className="p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-6">
            <div className="space-y-2">
              <h2 className="text-xl font-bold text-white">
                Push Part 4 Changes to GitHub (act_like_it)
              </h2>
              <p className="text-sm text-slate-300">
                Push the Tri-Modal Judging Engine and Supabase Storage video loop controller directly from Google AI Studio:
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">01. Open GitHub Tab</div>
                <h3 className="text-base font-semibold text-white">
                  Verify Staged Part 4 Files
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Verify that <code className="font-mono text-white">lib/judging_engine.dart</code> and the updated <code className="font-mono text-white">lib/webrtc_manager.dart</code> appear in your GitHub sync list.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">02. Sync to GitHub</div>
                <h3 className="text-base font-semibold text-white">
                  Tap &ldquo;Push Changes&rdquo;
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Commit and push Part 4 directly to your private <code className="font-mono text-white">act_like_it</code> repository on GitHub.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">03. Advance to Part 5</div>
                <h3 className="text-base font-semibold text-white">
                  Confirm Completion
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Once pushed, instruct me to proceed to the final batch: Part 5 (Late-Night After-Hours Module).
                </p>
              </div>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}
