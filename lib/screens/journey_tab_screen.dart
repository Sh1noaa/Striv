import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/strive_models.dart';
import '../services/storage_service.dart';
import '../widgets/ignis_mascot_widget.dart';
import '../widgets/strive_3d_button.dart';
import '../widgets/strive_theme.dart';
import 'workout_timer_sheet.dart';

class JourneyTabScreen extends StatelessWidget {
  final VoidCallback onOpenTimer;
  final ValueChanged<int> onSwitchTab;

  const JourneyTabScreen({
    super.key,
    required this.onOpenTimer,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final profile = storage.profile;
    final filter = storage.activeTrackFilter; // 'Semua', 'UTBK & TKA', 'Kedinasan'

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Interactive Ignis Mascot Header Banner
          IgnisMascotWidget(
            mood: storage.currentIgnisMood,
            speechText: storage.currentIgnisSpeech,
            equippedAccessory: storage.equippedAccessory,
            interactiveMoodCycle: true,
            onTap: () => storage.cyclePreviewMood(),
            size: 98,
          ),
          const SizedBox(height: 12),

          // Quick Action Row: Start Today's Session + Load 4-Month Demo Data (if empty)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Strive3DButton(
                  color: StriveColors.emerald,
                  onPressed: onOpenTimer,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'MULAI LATIHAN HARI INI',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (storage.utbkTryouts.isEmpty && storage.skdTryouts.isEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Strive3DButton(
                    color: StriveColors.indigo,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                    onPressed: () async {
                      await storage.loadFourMonthRealisticDemoData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: StriveColors.indigo,
                            content: Text(
                              '⚡ Data Demo Realistis 4 Bulan Berhasil Dimuat!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      '⚡ Muat Demo 4Bln',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // 2. DUAL RPG BOSS FIGHTS
          const Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: StriveColors.rose),
              SizedBox(width: 6),
              Text(
                'DUAL RPG BOSS FIGHTS (MENUJU 2027)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (filter == 'Semua' || filter == 'UTBK & TKA') ...[
            _buildAcademicPtnBossCard(context, storage, profile),
            const SizedBox(height: 12),
          ],

          if (filter == 'Semua' || filter == 'Kedinasan') ...[
            _buildSkdKedinasanBossCard(context, storage, profile),
            const SizedBox(height: 12),
            _buildPhysicalSamaptaBossCard(context, storage, profile),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 10),

          // 3. DUOLINGO-STYLE WINDING JOURNEY MAP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.map_rounded, color: StriveColors.emerald),
                  SizedBox(width: 6),
                  Text(
                    'PETA PERJALANAN PEJUANG 2027',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StriveColors.emerald.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level ${storage.level} • ${storage.exp} EXP',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: StriveColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _WindingJourneyMapWidget(
            storage: storage,
            onNodeTap: (index) {
              if (index == 2 || index == 4) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const WorkoutTimerSheet(initialTabIndex: 1),
                );
              } else {
                onOpenTimer();
              }
            },
          ),
          const SizedBox(height: 22),

          // 4. GITHUB-STYLE CONTRIBUTION HEATMAP
          const Row(
            children: [
              Icon(Icons.grid_view_rounded, color: StriveColors.emerald),
              SizedBox(width: 6),
              Text(
                'HEATMAP KONTRIBUSI LATIHAN (84 HARI)',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ContributionHeatmapCard(storage: storage),
        ],
      ),
    );
  }

  Widget _buildAcademicPtnBossCard(
    BuildContext context,
    StorageService storage,
    UserProfile? profile,
  ) {
    final targetScore = profile?.targetUtbkScore ?? 745.0;
    final currentAvg = storage.averageUtbkScore;
    final gap = (targetScore - currentAvg).clamp(0.0, targetScore);
    // Boss HP remaining %: 100% when currentAvg=0, 0% when currentAvg >= targetScore
    final bossHpPercent =
        targetScore > 0 ? (gap / targetScore).clamp(0.0, 1.0) : 0.0;
    final damageDealtPercent = (1.0 - bossHpPercent).clamp(0.0, 1.0);
    final isDefeated = currentAvg >= targetScore && currentAvg > 0;

    return Strive3DCard(
      borderColor: isDefeated ? StriveColors.emerald : StriveColors.indigo,
      onTap: () => onSwitchTab(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StriveColors.indigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: StriveColors.indigo,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACADEMIC BOSS: ${profile?.targetPtnName ?? "PTN Impian"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      profile?.targetPtnMajor ?? 'STEI - Komputasi',
                      style: TextStyle(
                        fontSize: 12,
                        color: StriveColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isDefeated ? StriveColors.emerald : StriveColors.rose)
                      .withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isDefeated
                      ? '🏆 BOSS TAKLUK'
                      : 'HP: ${(bossHpPercent * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color:
                        isDefeated ? StriveColors.emerald : StriveColors.rose,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Boss HP Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: damageDealtPercent,
              minHeight: 14,
              backgroundColor: StriveColors.rose.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDefeated ? StriveColors.emerald : StriveColors.indigo,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rata-rata UTBK: ${currentAvg.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Target Passing: ${targetScore.toStringAsFixed(0)} (Gap: -${gap.toStringAsFixed(0)} pts)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDefeated ? StriveColors.emerald : StriveColors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkdKedinasanBossCard(
    BuildContext context,
    StorageService storage,
    UserProfile? profile,
  ) {
    final targetSkd = profile?.targetSkdScore ?? 452;
    final latestSkd = storage.latestSkdTotal;
    final gap = (targetSkd - latestSkd).clamp(0, targetSkd);
    final progress =
        targetSkd > 0 ? (latestSkd / targetSkd).clamp(0.0, 1.0) : 0.0;
    final passedAmbang =
        storage.skdTryouts.isNotEmpty && storage.skdTryouts.first.passedAll;

    return Strive3DCard(
      borderColor: StriveColors.amber,
      onTap: () => onSwitchTab(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StriveColors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: StriveColors.amber,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KEDINASAN BOSS: ${profile?.targetKedinasanName ?? "PKN STAN"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${profile?.targetKedinasanMajor ?? "D4 Akuntansi"} • BKN Ambang Batas',
                      style: TextStyle(
                        fontSize: 12,
                        color: StriveColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (passedAmbang
                          ? StriveColors.emerald
                          : StriveColors.rose)
                      .withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  storage.skdTryouts.isEmpty
                      ? 'BELUM TES'
                      : (passedAmbang ? 'LULUS AMBANG' : 'NILAI MATI'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: passedAmbang
                        ? StriveColors.emerald
                        : StriveColors.rose,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 13,
              backgroundColor: StriveColors.amber.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(StriveColors.amber),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor SKD Terakhir: $latestSkd / 550',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Target Aman: $targetSkd (Defisit: -$gap)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: StriveColors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalSamaptaBossCard(
    BuildContext context,
    StorageService storage,
    UserProfile? profile,
  ) {
    final targetSamapta = profile?.targetSamaptaScore ?? 75.0;
    final currentSamapta = storage.latestSamaptaScore;
    final gap = (targetSamapta - currentSamapta).clamp(0.0, 100.0);
    final progress = (currentSamapta / 100.0).clamp(0.0, 1.0);
    final isSafe = currentSamapta >= 70.0;
    final latestLog =
        storage.samaptaLogs.isNotEmpty ? storage.samaptaLogs.first : null;

    return Strive3DCard(
      borderColor: isSafe ? StriveColors.emerald : StriveColors.rose,
      onTap: () => onSwitchTab(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSafe ? StriveColors.emerald : StriveColors.rose)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: isSafe ? StriveColors.emerald : StriveColors.rose,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PHYSICAL BOSS: SAMAPTA READINESS (${profile?.gender ?? "Pria"})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      latestLog != null
                          ? 'Lari ${latestLog.lari12MenitMeters.toInt()}m • ${profile?.gender == "Wanita" ? "Chinning" : "Pull-up"} ${latestLog.pullUpOrChinningReps}x • Shuttle ${latestLog.shuttleRunSeconds}s'
                          : 'Batas Aman Fisik Kedinasan >= 70.0 Poin',
                      style: TextStyle(
                        fontSize: 12,
                        color: StriveColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isSafe ? StriveColors.emerald : StriveColors.rose)
                      .withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isSafe ? 'FISIK SIAP' : 'ZONA BAHAYA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isSafe ? StriveColors.emerald : StriveColors.rose,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 13,
              backgroundColor: StriveColors.rose.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isSafe ? StriveColors.emerald : StriveColors.rose,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor Samapta: ${currentSamapta.toStringAsFixed(1)} / 100',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Target Aman: ${targetSamapta.toStringAsFixed(0)}+ (Gap: -${gap.toStringAsFixed(1)})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSafe ? StriveColors.emerald : StriveColors.rose,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WindingJourneyMapWidget extends StatelessWidget {
  final StorageService storage;
  final ValueChanged<int> onNodeTap;

  const _WindingJourneyMapWidget({
    required this.storage,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final milestones = [
      (
        'Stage 1: Fondasi Logika & Nalar',
        'Kuasai PU, PBM, PPU & Wawasan Kebangsaan Dasar',
        Icons.menu_book_rounded,
        StriveColors.emerald,
        true,
      ),
      (
        'Stage 2: Gebrakan Kuantitatif & TIU',
        'Babat Habis PK, PM, Hitung Cepat & Figural CAT',
        Icons.calculate_rounded,
        StriveColors.sky,
        storage.dailyLogs.length >= 3,
      ),
      (
        'Stage 3: Kawah Candradimuka Samapta',
        'Tembus Lari 2400m+, Pull-up 10x & Shuttle Run < 17.5s',
        Icons.fitness_center_rounded,
        StriveColors.amber,
        storage.samaptaLogs.isNotEmpty,
      ),
      (
        'Stage 4: Pendalaman TKA & Pauli Endurance',
        'TKA Saintek/Soshum HOTS + Stabilitas Grafik Kraepelin',
        Icons.science_rounded,
        StriveColors.indigo,
        storage.utbkTryouts.length >= 2,
      ),
      (
        'Stage 5: Simulasi Akbar Tanpa Celah',
        'Lulus Ambang Batas SKD 440+ & UTBK Rata-rata 720+',
        Icons.workspace_premium_rounded,
        StriveColors.purple,
        storage.averageUtbkScore >= 690 || storage.latestSkdTotal >= 420,
      ),
      (
        'FINAL BOSS: Hari-H UTBK & Kedinasan 2027',
        'Mei 2027 • Buka Kapsul Waktu & Jemput Almamater Impian!',
        Icons.emoji_events_rounded,
        StriveColors.rose,
        false,
      ),
    ];

    // Offsets for Duolingo-style winding left-center-right curve
    const xAlignments = [-0.45, 0.35, -0.35, 0.45, -0.25, 0.0];

    return Strive3DCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _WindingPathPainter(
                xAlignments: xAlignments,
                unlockedCount:
                    milestones.where((m) => m.$5).length.clamp(1, 6),
              ),
            ),
          ),
          Column(
            children: List.generate(milestones.length, (i) {
              final m = milestones[i];
              final alignX = xAlignments[i];
              final unlocked = m.$5;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: i == milestones.length - 1 ? 0 : 24,
                ),
                child: Align(
                  alignment: Alignment(alignX, 0),
                  child: GestureDetector(
                    onTap: () => onNodeTap(i),
                    child: Container(
                      width: 245,
                      padding: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? m.$4.withValues(alpha: 0.75)
                            : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: StriveColors.surface(context),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: unlocked ? m.$4 : Colors.grey.shade600,
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: unlocked ? m.$4 : Colors.grey.shade700,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (unlocked ? m.$4 : Colors.black)
                                        .withValues(alpha: 0.35),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(
                                m.$3,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.$1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12.5,
                                      color: unlocked
                                          ? m.$4
                                          : StriveColors.textPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m.$2,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          StriveColors.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WindingPathPainter extends CustomPainter {
  final List<double> xAlignments;
  final int unlockedCount;

  _WindingPathPainter({
    required this.xAlignments,
    required this.unlockedCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (xAlignments.length < 2) return;
    final stepHeight = size.height / xAlignments.length;

    for (int i = 0; i < xAlignments.length - 1; i++) {
      final x1 = (size.width / 2) + (xAlignments[i] * (size.width * 0.25));
      final y1 = (i * stepHeight) + 38;
      final x2 = (size.width / 2) + (xAlignments[i + 1] * (size.width * 0.25));
      final y2 = ((i + 1) * stepHeight) + 38;

      final isActive = i < unlockedCount;
      final paint = Paint()
        ..color = isActive
            ? StriveColors.emerald.withValues(alpha: 0.55)
            : Colors.grey.withValues(alpha: 0.3)
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(x1, y1)
        ..cubicTo(
          x1,
          (y1 + y2) / 2,
          x2,
          (y1 + y2) / 2,
          x2,
          y2,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WindingPathPainter oldDelegate) =>
      oldDelegate.unlockedCount != unlockedCount;
}

class _ContributionHeatmapCard extends StatelessWidget {
  final StorageService storage;
  const _ContributionHeatmapCard({required this.storage});

  @override
  Widget build(BuildContext context) {
    // Map YYYY-MM-DD -> total minutes
    final minutesByDay = <String, int>{};
    for (final log in storage.dailyLogs) {
      minutesByDay[log.date] = (minutesByDay[log.date] ?? 0) + log.minutes;
    }

    final today = DateTime.now();
    // 84 days = 12 weeks x 7 days
    final days = List.generate(84, (index) {
      final d = today.subtract(Duration(days: 83 - index));
      final key = DateFormat('yyyy-MM-dd').format(d);
      return (key, minutesByDay[key] ?? 0);
    });

    final totalMinutes84 =
        days.fold<int>(0, (sum, item) => sum + item.$2);
    final activeDays84 = days.where((item) => item.$2 > 0).length;

    Color cellColor(int mins, bool isDark) {
      if (mins <= 0) {
        return isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFE2E8F0);
      }
      if (mins < 30) return StriveColors.emerald.withValues(alpha: 0.35);
      if (mins < 60) return StriveColors.emerald.withValues(alpha: 0.60);
      if (mins < 90) return StriveColors.emerald.withValues(alpha: 0.85);
      return StriveColors.emerald;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Strive3DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$activeDays84 Hari Aktif • ${(totalMinutes84 / 60).toStringAsFixed(1)} Jam Total',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Text(
                '12 Minggu Terakhir',
                style: TextStyle(
                  fontSize: 11.5,
                  color: StriveColors.emerald,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: days.length,
              itemBuilder: (context, idx) {
                final entry = days[idx];
                return Tooltip(
                  message: '${entry.$1}: ${entry.$2} menit',
                  child: Container(
                    decoration: BoxDecoration(
                      color: cellColor(entry.$2, isDark),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Rebahan ',
                style: TextStyle(
                  fontSize: 11,
                  color: StriveColors.textSecondary(context),
                ),
              ),
              for (final m in [0, 20, 45, 75, 100])
                Container(
                  width: 13,
                  height: 13,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: cellColor(m, isDark),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              Text(
                ' Ambis',
                style: TextStyle(
                  fontSize: 11,
                  color: StriveColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
