import React, { useState } from 'react';
import {
  CheckCircle2,
  Copy,
  Check,
  FileCode2,
  GitBranch,
  Smartphone,
  Layers,
  Film,
  Radio,
  Database,
  ShieldAlert,
} from 'lucide-react';
import {
  BATCH_STAGES,
  PART_1_FILES,
  getBatchCompletionRatio,
} from './utils/part1Specs';

export default function App() {
  const [selectedFilePath, setSelectedFilePath] = useState<string>('pubspec.yaml');
  const [copiedPath, setCopiedPath] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'files' | 'sync-guide' | 'preview'>('files');
  const [previewCategory, setPreviewCategory] = useState<string>('Eras (1970–1999)');
  const [lateNightPreviewToggle, setLateNightPreviewToggle] = useState<boolean>(false);

  const selectedFile =
    PART_1_FILES.find((f) => f.path === selectedFilePath) ?? PART_1_FILES[0];
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
            Part 1 Files
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
          <button
            type="button"
            onClick={() => setActiveTab('preview')}
            className={`hover:text-white transition-colors whitespace-nowrap shrink-0 ${
              activeTab === 'preview' ? 'text-white underline underline-offset-8' : ''
            }`}
          >
            Soundstage Shell Preview
          </button>
        </nav>

        <div className="flex items-center gap-3 shrink-0">
          <button
            type="button"
            onClick={() => setActiveTab('sync-guide')}
            className="px-4 py-2 text-xs font-semibold text-white bg-rose-600 rounded-lg hover:bg-rose-500 transition-colors whitespace-nowrap shrink-0"
          >
            GitHub Push Instructions
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
                <span>Batch 1 of 5 Ready</span>
              </div>
              <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
                Part 1: Initialization & Dependencies Generated
              </h1>
              <p className="text-sm text-slate-300 leading-relaxed">
                The root Flutter directory structure (<code className="font-mono text-amber-400">pubspec.yaml</code>,{' '}
                <code className="font-mono text-amber-400">analysis_options.yaml</code>, and{' '}
                <code className="font-mono text-amber-400">lib/main.dart</code>) has been written directly to this
                AI Studio workspace for direct GitHub synchronization.
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
              Part 1 Files
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
            <button
              type="button"
              onClick={() => setActiveTab('preview')}
              className={`flex-1 px-3 py-2 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                activeTab === 'preview'
                  ? 'bg-slate-800 text-white'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Shell Preview
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
                  Part 1 Workspace Files
                </h2>
                <div className="space-y-2">
                  {PART_1_FILES.map((file) => {
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
                          {file.lineCount} lines
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

        {/* Tab 2: GitHub Sync Guide for Galaxy S26 Ultra */}
        {activeTab === 'sync-guide' && (
          <section className="p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-6">
            <div className="space-y-2">
              <h2 className="text-xl font-bold text-white">
                GitHub Sync Workflow (Samsung Galaxy S26 Ultra — Zero Local Storage)
              </h2>
              <p className="text-sm text-slate-300">
                Follow these steps inside the Google AI Studio interface to push Part 1 directly to your remote GitHub repository without downloading files or opening a terminal:
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">01. Open Settings Toolbar</div>
                <h3 className="text-base font-semibold text-white">
                  Navigate to the GitHub Tab
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Tap the Settings icon in the top toolbar of Google AI Studio on your Galaxy S26 Ultra browser and select the GitHub integration tab.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">02. Provision Repository</div>
                <h3 className="text-base font-semibold text-white">
                  Create Private Repo: act_like_it
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Create a new private repository named <code className="font-mono text-white">act_like_it</code> directly from the GitHub tab and bind this workspace.
                </p>
              </div>

              <div className="p-5 rounded-lg bg-slate-950 border border-slate-800 space-y-2">
                <div className="text-xs font-mono text-amber-400">03. Push Batch 1</div>
                <h3 className="text-base font-semibold text-white">
                  Stage & Push Initial Files
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Tap &ldquo;Push Changes&rdquo; (Sync to GitHub) to commit <code className="font-mono text-white">pubspec.yaml</code>, <code className="font-mono text-white">analysis_options.yaml</code>, and <code className="font-mono text-white">lib/main.dart</code>, then reply in chat to proceed to Part 2.
                </p>
              </div>
            </div>
          </section>
        )}

        {/* Tab 3: Interactive Preview of SoundstageShellScreen (lib/main.dart) */}
        {activeTab === 'preview' && (
          <section className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
            <div className="lg:col-span-5 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-4">
              <h2 className="text-lg font-bold text-white">
                Flutter SoundstageShellScreen Preview
              </h2>
              <p className="text-sm text-slate-300 leading-relaxed">
                This interactive preview mirrors the widget hierarchy defined in{' '}
                <code className="font-mono text-amber-400">lib/main.dart</code>: portrait stage lock, Supabase 10 EPS Realtime initialization, Tri-Modal Judging architecture overview, and the scene category vault selectors.
              </p>
              <div className="space-y-2 pt-2 text-xs text-slate-400">
                <div>
                  <strong className="text-slate-200">Selected Vault:</strong> {previewCategory}
                </div>
                <div>
                  <strong className="text-slate-200">Late-Night 18+ Vault Gate:</strong>{' '}
                  {lateNightPreviewToggle ? 'Unlocked (Ready for Part 5 RLS)' : 'Locked'}
                </div>
              </div>
            </div>

            <div className="lg:col-span-7 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
              <div className="flex items-center justify-between pb-3 border-b border-slate-800">
                <span className="text-base font-bold text-white">Act Like It</span>
                <span className="text-xs text-slate-400">
                  SFU 2–8 Players · Tri-Modal Judging
                </span>
              </div>

              <div className="p-4 rounded-lg bg-slate-950 border border-slate-800 space-y-3">
                <h3 className="text-lg font-bold text-white">
                  Live Soundstage & Telemetrics Engine
                </h3>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Enter a 6-digit lobby code or host a remote 2–8 player LiveKit SFU room. Perform iconic cinema prompts live while Gemini Multimodal AI and peers score your emotional cadence.
                </p>
                <div className="grid grid-cols-2 gap-3 pt-1">
                  <button
                    type="button"
                    onClick={() => setActiveTab('files')}
                    className="px-4 py-2.5 text-xs font-semibold text-white bg-rose-600 rounded-lg hover:bg-rose-500 transition-colors whitespace-nowrap shrink-0"
                  >
                    Create 6-Digit Lobby
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveTab('files')}
                    className="px-4 py-2.5 text-xs font-semibold text-slate-200 bg-slate-900 border border-slate-700 rounded-lg hover:bg-slate-800 transition-colors whitespace-nowrap shrink-0"
                  >
                    Join Room Code
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <div className="text-xs font-semibold text-slate-300">
                  Supabase Scene Vaults
                </div>
                {[
                  {
                    group: 'Eras (1970–1999)',
                    subtitle: 'New Hollywood & Blockbuster Golden Age',
                    table: 'scenes_era_1970_1999',
                  },
                  {
                    group: 'Eras (2000–2026)',
                    subtitle: 'Modern Prestige Cinema & Streaming Defining Moments',
                    table: 'scenes_era_2000_2026',
                  },
                  {
                    group: 'Awards Vault',
                    subtitle: 'Best Actor · Best Actress · Best Villain · Emmy Vault',
                    table: 'scenes_awards_vault',
                  },
                  {
                    group: 'Specialty',
                    subtitle: 'Cult Classics & Unforgettable Monologues',
                    table: 'scenes_cult_classics',
                  },
                ].map((item) => {
                  const active = previewCategory === item.group;
                  return (
                    <button
                      key={item.group}
                      type="button"
                      onClick={() => setPreviewCategory(item.group)}
                      className={`w-full text-left p-3 rounded-lg border transition-colors flex items-center justify-between gap-4 ${
                        active
                          ? 'bg-slate-800 border-rose-500'
                          : 'bg-slate-950 border-slate-800 hover:border-slate-700'
                      }`}
                    >
                      <div>
                        <div className="text-xs font-semibold text-white">
                          {item.group}
                        </div>
                        <div className="text-xs text-slate-400">{item.subtitle}</div>
                      </div>
                      <span className="font-mono text-xs text-amber-400 shrink-0">
                        {item.table}
                      </span>
                    </button>
                  );
                })}
              </div>

              <div className="p-3.5 rounded-lg bg-slate-950 border border-slate-800 flex items-center justify-between gap-4">
                <div>
                  <div className="text-xs font-semibold text-white">
                    Late-Night After-Hours Vault (18+)
                  </div>
                  <div className="text-xs text-slate-400">
                    Hidden, age-gated Supabase table configured in Part 5.
                  </div>
                </div>
                <button
                  type="button"
                  role="switch"
                  aria-checked={lateNightPreviewToggle}
                  aria-label="Toggle Late-Night After-Hours Vault preview"
                  onClick={() => setLateNightPreviewToggle((prev) => !prev)}
                  className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors whitespace-nowrap shrink-0 ${
                    lateNightPreviewToggle
                      ? 'bg-rose-600 text-white'
                      : 'bg-slate-800 text-slate-300'
                  }`}
                >
                  {lateNightPreviewToggle ? 'Unlocked' : 'Locked'}
                </button>
              </div>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}
