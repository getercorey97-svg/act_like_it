import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/nda_tester_gate.dart';
import '../main.dart';
import 'qa_overlay.dart';

/// Desktop-optimized Companion Web Portal Dashboard (`lib/qa/qa_web_portal.dart`)
/// Mounted at the hidden `/qa-dashboard` route on `act-like-it.vercel.app` (and
/// accessible from the in-app QA overlay for instant telemetry inspection).
class QaWebPortalDashboardScreen extends StatefulWidget {
  const QaWebPortalDashboardScreen({super.key});

  @override
  State<QaWebPortalDashboardScreen> createState() =>
      _QaWebPortalDashboardScreenState();
}

class _QaWebPortalDashboardScreenState
    extends State<QaWebPortalDashboardScreen> {
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSub;
  List<QaFeedbackReport> _cloudReports = <QaFeedbackReport>[];
  List<QaFeedbackReport> _localReports = <QaFeedbackReport>[];
  String _selectedBugFilter = 'ALL';
  String? _selectedReportId;
  bool _isLoading = true;
  String _connectionStatus = 'CONNECTING TO SUPABASE REALTIME...';

  static final List<QaFeedbackReport> _seedAlphaReports = <QaFeedbackReport>[
    QaFeedbackReport(
      id: 'soa-alpha-001',
      testerHandle: '@s26_ultra_lead',
      appVersion: '1.0.0+1 (S.O.A. Alpha)',
      bugType: 'AI Score',
      screenshotUrl: '/app_logo.png',
      deviceInfo: const <String, dynamic>{
        'screen_resolution_px': '1440x3120',
        'logical_viewport_dp': '412x892',
        'device_pixel_ratio': 3.5,
        'platform': 'android',
        'os': 'Android 16 (SDK 36)',
        'device_model': 'Samsung SM-S948U (Galaxy S26 Ultra)',
      },
      localStateDump: const <String, dynamic>{
        'tester_note':
            'Gemini 2.5 Flash ruthless calibration verified: scored 82.5 (70-89_AVERAGE_ATTEMPT) with facial timestamp @ 680ms and vocal peak @ 2640ms (-13.4 dBFS).',
        'active_page_route': '/tri-modal-verdict',
        'route_breadcrumb': <String>[
          '/dashboard-marquee',
          '/lobby-matchmaking',
          '/soundstage-webrtc',
          '/tri-modal-verdict',
        ],
        'shared_preferences_dump': <String, dynamic>{
          'is_tester': true,
          'act_like_it_last_user_id_v1': 'actor_s26_prime',
          'act_like_it_telemetrics_tokens_v1': 24,
          'offline_cached_scene_packs_v2': '<90_general_scenes_cached>',
          'offline_cached_late_night_v2': '<10_adult_scenes_cached>',
        },
      },
      createdAt: DateTime.utc(2026, 10, 24, 10, 15),
    ),
    QaFeedbackReport(
      id: 'soa-alpha-002',
      testerHandle: '@method_queen_ny',
      appVersion: '1.0.0+1 (S.O.A. Alpha)',
      bugType: 'UI',
      screenshotUrl: '/app_logo.png',
      deviceInfo: const <String, dynamic>{
        'screen_resolution_px': '1080x2340',
        'logical_viewport_dp': '390x844',
        'device_pixel_ratio': 3.0,
        'platform': 'android',
        'os': 'Android 15 (SDK 35)',
        'device_model': 'Pixel 9 Pro',
      },
      localStateDump: const <String, dynamic>{
        'tester_note':
            'Checked Duet Lead A (#F5DEB3) & Lead B (#0CB6D4) teleprompter lines on "The Milkshake Straw" — zero text truncation.',
        'active_page_route': '/soundstage-webrtc',
        'route_breadcrumb': <String>[
          '/dashboard-marquee',
          '/scene-vault',
          '/soundstage-webrtc',
        ],
        'shared_preferences_dump': <String, dynamic>{
          'is_tester': true,
          'duet_split_screen_enabled': true,
          'active_room_code': '849201',
        },
      },
      createdAt: DateTime.utc(2026, 10, 24, 9, 42),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initPortalStreams();
  }

  Future<void> _initPortalStreams() async {
    final local = await QaTelemetryRepository.loadLocalCachedReports();
    if (mounted) {
      setState(() {
        _localReports = local;
      });
    }

    final client = supabaseOrNull;
    if (client != null) {
      try {
        final initialRows = await client
            .from(QaTelemetryRepository.tableName)
            .select()
            .order('created_at', ascending: false)
            .limit(100);
        final parsed = initialRows
            .whereType<Map>()
            .map((r) => QaFeedbackReport.fromJson(Map<String, dynamic>.from(r)))
            .toList();
        if (mounted) {
          setState(() {
            _cloudReports = parsed;
            _isLoading = false;
            _connectionStatus =
                'LIVE SUPABASE STREAM ACTIVE (public.qa_feedback)';
          });
        }

        _realtimeSub = client
            .from(QaTelemetryRepository.tableName)
            .stream(primaryKey: <String>['id'])
            .order('created_at', ascending: false)
            .listen(
              (List<Map<String, dynamic>> rows) {
                if (!mounted) return;
                setState(() {
                  _cloudReports =
                      rows.map(QaFeedbackReport.fromJson).toList();
                  _connectionStatus =
                      'LIVE SUPABASE STREAM ACTIVE (${_cloudReports.length} cloud rows)';
                });
              },
              onError: (_) {},
            );
        return;
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _connectionStatus =
            'HYBRID LOCAL + S.O.A. SEED STREAM (Connect Supabase for Cloud Sync)';
      });
    }
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }

  List<QaFeedbackReport> get _allMergedReports {
    final byId = <String, QaFeedbackReport>{};
    for (final r in _cloudReports) {
      byId[r.id] = r;
    }
    for (final r in _localReports) {
      byId.putIfAbsent(r.id, () => r);
    }
    if (byId.isEmpty) {
      for (final r in _seedAlphaReports) {
        byId[r.id] = r;
      }
    }
    final list = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_selectedBugFilter == 'ALL') return list;
    return list.where((r) => r.bugType == _selectedBugFilter).toList();
  }

  Color _badgeColorForBugType(String type) {
    switch (type) {
      case 'NDA_BREACH':
      case 'Crash':
        return const Color(0xFFE11D48);
      case 'NDA_SIGNED':
      case 'AI Score':
        return const Color(0xFFFFD700);
      case 'PASSCODE_VERIFIED':
      case 'Audio':
        return const Color(0xFF0CB6D4);
      case 'UI':
      default:
        return const Color(0xFF10B981);
    }
  }

  Widget _buildScreenshotPreview(String? url, {double height = 110}) {
    if (url == null || url.trim().isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E17),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: const Text(
          'NO SCREENSHOT',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    if (url.startsWith('data:image/')) {
      try {
        final commaIdx = url.indexOf(',');
        final b64 = commaIdx >= 0 ? url.substring(commaIdx + 1) : url;
        final bytes = base64Decode(b64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          alignment: Alignment.center,
          color: const Color(0xFF0A0E17),
          child: const Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  void _openScreenshotLightbox(QaFeedbackReport report) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0E131F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${report.testerHandle} · ${report.bugType} SNAPSHOT',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildScreenshotPreview(
                    report.screenshotUrl,
                    height: 540,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!OfficialClosedAlphaNdaGateWrapper.isSessionUnlockedSync()) {
      return const OfficialClosedAlphaNdaGateWrapper(
        child: QaWebPortalDashboardScreen(),
      );
    }

    final reports = _allMergedReports;
    final selectedReport = reports.firstWhere(
      (r) => r.id == _selectedReportId,
      orElse: () => reports.isNotEmpty
          ? reports.first
          : _seedAlphaReports.first,
    );
    final prettyStateJson = const JsonEncoder.withIndent('  ').convert(
      <String, dynamic>{
        'report_id': selectedReport.id,
        'tester_handle': selectedReport.testerHandle,
        'app_version': selectedReport.appVersion,
        'bug_type': selectedReport.bugType,
        'created_at': selectedReport.createdAt.toIso8601String(),
        'device_info': selectedReport.deviceInfo,
        'local_state_dump': selectedReport.localStateDump,
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D111A),
        title: const Text(
          'ACT LIKE IT · S.O.A. QA WEB PORTAL (/qa-dashboard)',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD700),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _connectionStatus,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktopWide = constraints.maxWidth >= 920;
            final filtersBar = Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'FILTER BUG TYPE:',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  ...<String>[
                    'ALL',
                    'NDA_SIGNED',
                    'NDA_BREACH',
                    'PASSCODE_VERIFIED',
                    'UI',
                    'Audio',
                    'AI Score',
                    'Crash',
                  ].map(
                    (filter) {
                      final active = _selectedBugFilter == filter;
                      return ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: active
                                ? const Color(0xFF07090E)
                                : const Color(0xFFF5DEB3),
                          ),
                        ),
                        selected: active,
                        selectedColor: const Color(0xFFFFD700),
                        backgroundColor: const Color(0xFF121826),
                        onSelected: (_) {
                          setState(() {
                            _selectedBugFilter = filter;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            );

            final mainTableAndGallery = ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Clickable Screenshot Gallery
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E131F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TESTER SCREENSHOT GALLERY (qa-screenshots BUCKET · CLICK TO ZOOM)',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0CB6D4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 145,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: reports.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (ctx, idx) {
                            final item = reports[idx];
                            final isSelected = item.id == selectedReport.id;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedReportId = item.id;
                                });
                                _openScreenshotLightbox(item);
                              },
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141B2B),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFD700)
                                        : const Color(0xFF334155),
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildScreenshotPreview(
                                        item.screenshotUrl,
                                        height: 90,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${item.testerHandle} (${item.bugType})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFF5DEB3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 2. Reported Bugs Data Table
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E131F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REPORTED BUGS DATA TABLE (${reports.length} ROWS)',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xFF141B2B),
                            ),
                            columns: const [
                              DataColumn(label: Text('TESTER')),
                              DataColumn(label: Text('TYPE')),
                              DataColumn(label: Text('ROUTE')),
                              DataColumn(label: Text('DEVICE / OS')),
                              DataColumn(label: Text('NOTE')),
                            ],
                            rows: reports.map((r) {
                              final selected = r.id == selectedReport.id;
                              final badgeColor = _badgeColorForBugType(
                                r.bugType,
                              );
                              final routeStr =
                                  (r.localStateDump['active_page_route'] ?? '/')
                                      .toString();
                              final osStr =
                                  '${r.deviceInfo['os'] ?? 'Android'} (${r.deviceInfo['screen_resolution_px'] ?? ''})';
                              final noteStr =
                                  (r.localStateDump['tester_note'] ?? '')
                                      .toString();

                              return DataRow(
                                selected: selected,
                                onSelectChanged: (_) {
                                  setState(() {
                                    _selectedReportId = r.id;
                                  });
                                },
                                cells: [
                                  DataCell(
                                    Text(
                                      r.testerHandle,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFF5DEB3),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: badgeColor),
                                      ),
                                      child: Text(
                                        r.bugType,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: badgeColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      routeStr,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: Color(0xFF0CB6D4),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      osStr,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 260,
                                      child: Text(
                                        noteStr,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );

            final sidePanelJsonInspector = Container(
              width: isDesktopWide ? 420 : double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E131F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'LOCAL_STATE_DUMP & DEVICE_INFO JSON',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: prettyStateJson),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Copied local_state_dump JSON to clipboard.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: Color(0xFF0CB6D4),
                        ),
                        label: const Text(
                          'COPY JSON',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            color: Color(0xFF0CB6D4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07090E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          prettyStateJson,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.4,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                filtersBar,
                Expanded(
                  child: isDesktopWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: mainTableAndGallery),
                            sidePanelJsonInspector,
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(flex: 3, child: mainTableAndGallery),
                            SizedBox(height: 280, child: sidePanelJsonInspector),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
