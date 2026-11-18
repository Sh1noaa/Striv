import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/strive_models.dart';
import '../services/storage_service.dart';
import '../widgets/ignis_mascot_widget.dart';
import '../widgets/strive_3d_button.dart';
import '../widgets/strive_theme.dart';

class AnalyticsTabScreen extends StatefulWidget {
  const AnalyticsTabScreen({super.key});

  @override
  State<AnalyticsTabScreen> createState() => _AnalyticsTabScreenState();
}

class _AnalyticsTabScreenState extends State<AnalyticsTabScreen> {
  String _selectedTrajectoryItem = 'UTBK Avg';
  String _selectedQuadrantMonth = '2026-11';

  static const List<String> _trajectoryFilters = [
    'UTBK Avg',
    'PU',
    'PK',
    'PM',
    'LBI',
    'LBE',
    'MTK_L',
    'FIS',
    'SKD Total',
    'Samapta',
  ];

  static const List<(String, String)> _monthFilters = [
    ('Semua', 'Semua Bulan'),
    ('2026-08', 'Agu 2026'),
    ('2026-09', 'Sep 2026'),
    ('2026-10', 'Okt 2026'),
    ('2026-11', 'Nov 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final hasAnyData = storage.utbkTryouts.isNotEmpty ||
        storage.skdTryouts.isNotEmpty ||
        storage.samaptaLogs.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasAnyData) ...[
            Strive3DCard(
              borderColor: StriveColors.indigo,
              child: Column(
                children: [
                  const IgnisMascotWidget(
                    mood: IgnisMood.coachSpartan,
                    speechText:
                        'Belum ada data TryOut untuk digambar di bidang Kartesius! Muat Data Demo 4 Bulan atau input TryOut pertamamu di Tab 3!',
                    size: 86,
                  ),
                  const SizedBox(height: 12),
                  Strive3DButton(
                    fullWidth: true,
                    color: StriveColors.indigo,
                    onPressed: () => storage.loadFourMonthRealisticDemoData(),
                    child: const Text(
                      '⚡ MUAT DATA REALISTIS 4 BULAN (DEMO)',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 1. DYNAMIC SUBTEST AVERAGE & BKN SKD PASSING GRADE ENGINE
          _buildDynamicSubtestEngineCard(context, storage),
          const SizedBox(height: 18),

          // 2. CARTESIAN DIAGRAM 1: MONTH-TO-MONTH TRAJECTORY (LineChart)
          _buildTrajectoryLineChartCard(context, storage),
          const SizedBox(height: 18),

          // 3. CARTESIAN DIAGRAM 2: 4-QUADRANT EFFORT VS SCORE PLANE (ScatterChart)
          _buildFourQuadrantScatterCard(context, storage),
          const SizedBox(height: 18),

          // 4. MULTI-TRACK RADAR CHART & DEFICIT GAP ANALYZER
          _buildRadarAndGapAnalyzerCard(context, storage),
        ],
      ),
    );
  }

  Widget _buildDynamicSubtestEngineCard(
    BuildContext context,
    StorageService storage,
  ) {
    final avgs = storage.subtestAverages;
    final latestSkd =
        storage.skdTryouts.isNotEmpty ? storage.skdTryouts.first : null;

    return Strive3DCard(
      borderColor: StriveColors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_rounded, color: StriveColors.indigo),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ENGINE RATA-RATA SUBTES & AMBANG BATAS BKN',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricSummaryBox(
                  context,
                  label: 'RATA-RATA UTBK',
                  value: storage.averageUtbkScore.toStringAsFixed(0),
                  sub: 'Target: ${storage.profile?.targetUtbkScore.toInt() ?? 745}',
                  color: StriveColors.emerald,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricSummaryBox(
                  context,
                  label: 'RATA-RATA TKA',
                  value: storage.averageTkaScore.toStringAsFixed(0),
                  sub: storage.profile?.tkaCategory ?? 'Saintek',
                  color: StriveColors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricSummaryBox(
                  context,
                  label: 'SKD CAT BKN',
                  value: '${storage.latestSkdTotal}/550',
                  sub: latestSkd == null
                      ? 'Belum Tes'
                      : (latestSkd.passedAll ? 'LULUS AMBANG' : 'GUGUR'),
                  color: (latestSkd?.passedAll ?? false)
                      ? StriveColors.amber
                      : StriveColors.rose,
                ),
              ),
            ],
          ),
          if (latestSkd != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: StriveColors.background(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: StriveColors.border(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bknThresholdChip('TWK', latestSkd.twk, 65),
                  _bknThresholdChip('TIU', latestSkd.tiu, 80),
                  _bknThresholdChip('TKP', latestSkd.tkp, 166),
                ],
              ),
            ),
          ],
          if (avgs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: avgs.entries.map((entry) {
                final target = storage.profile?.targetUtbkScore ?? 710.0;
                final good = entry.value >= target;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: (good ? StriveColors.emerald : StriveColors.amber)
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (good ? StriveColors.emerald : StriveColors.amber)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: good ? StriveColors.emerald : StriveColors.amber,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricSummaryBox(
    BuildContext context, {
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: StriveColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bknThresholdChip(String code, int score, int passing) {
    final passed = score >= passing;
    final col = passed ? StriveColors.emerald : StriveColors.rose;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Icons.verified_rounded : Icons.warning_amber_rounded,
          size: 16,
          color: col,
        ),
        const SizedBox(width: 4),
        Text(
          '$code: $score/$passing',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: col,
          ),
        ),
      ],
    );
  }

  Widget _buildTrajectoryLineChartCard(
    BuildContext context,
    StorageService storage,
  ) {
    // Build chronological trajectory points for the selected filter
    final points = <(String, double)>[];
    double targetLine = storage.profile?.targetUtbkScore ?? 745.0;
    double minY = 450;
    double maxY = 850;

    if (_selectedTrajectoryItem == 'SKD Total') {
      targetLine = (storage.profile?.targetSkdScore ?? 452).toDouble();
      minY = 250;
      maxY = 550;
      final sorted = List<SkdTryout>.from(storage.skdTryouts)
        ..sort((a, b) => a.date.compareTo(b.date));
      for (final s in sorted) {
        points.add((_shortMonthLabel(s.date), s.totalScore.toDouble()));
      }
    } else if (_selectedTrajectoryItem == 'Samapta') {
      targetLine = storage.profile?.targetSamaptaScore ?? 75.0;
      minY = 0;
      maxY = 100;
      final sorted = List<SamaptaLog>.from(storage.samaptaLogs)
        ..sort((a, b) => a.date.compareTo(b.date));
      for (final s in sorted) {
        points.add((_shortMonthLabel(s.date), s.finalScore));
      }
    } else if (_selectedTrajectoryItem == 'UTBK Avg') {
      final sorted = storage.utbkTryouts
          .where((e) => e.category == 'UTBK')
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      for (final t in sorted) {
        points.add((_shortMonthLabel(t.date), t.averageScore));
      }
    } else {
      final sorted = List<UtbkTkaTryout>.from(storage.utbkTryouts)
        ..sort((a, b) => a.date.compareTo(b.date));
      for (final t in sorted) {
        final val = t.subtestScores[_selectedTrajectoryItem];
        if (val != null) {
          points.add((_shortMonthLabel(t.date), val));
        }
      }
    }

    // Fallback preview points if empty so chart never crashes
    if (points.isEmpty) {
      points.addAll([
        ('Agu 26', targetLine * 0.82),
        ('Sep 26', targetLine * 0.87),
        ('Okt 26', targetLine * 0.93),
        ('Nov 26', targetLine * 0.98),
      ]);
    }

    final spots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].$2.clamp(minY, maxY)),
    );

    return Strive3DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, color: StriveColors.emerald),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DIAGRAM KARTESIUS 1: TRAJECTORY BULANAN',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Garis putus-putus horizontal menunjukkan Target Passing Score (${targetLine.toStringAsFixed(0)}).',
            style: TextStyle(
              fontSize: 12,
              color: StriveColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _trajectoryFilters.map((item) {
                final selected = _selectedTrajectoryItem == item;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    selected: selected,
                    selectedColor: StriveColors.emerald.withValues(alpha: 0.25),
                    onSelected: (_) =>
                        setState(() => _selectedTrajectoryItem = item),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (points.length - 1).clamp(1, 20).toDouble(),
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (_) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.35),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: targetLine.clamp(minY, maxY),
                      color: StriveColors.amber,
                      strokeWidth: 2.2,
                      dashArray: [8, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: StriveColors.amber,
                        ),
                        labelResolver: (_) =>
                            'TARGET ${targetLine.toStringAsFixed(0)}',
                      ),
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: StriveColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            points[idx].$1,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: StriveColors.emerald,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: StriveColors.emerald.withValues(alpha: 0.16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortMonthLabel(String isoDate) {
    if (isoDate.length < 7) return isoDate;
    final ym = isoDate.substring(0, 7);
    switch (ym) {
      case '2026-08':
        return 'Agu 26';
      case '2026-09':
        return 'Sep 26';
      case '2026-10':
        return 'Okt 26';
      case '2026-11':
        return 'Nov 26';
      case '2026-12':
        return 'Des 26';
      case '2027-01':
        return 'Jan 27';
      default:
        return isoDate.substring(5);
    }
  }

  Widget _buildFourQuadrantScatterCard(
    BuildContext context,
    StorageService storage,
  ) {
    // Calculate (Hours Logged, Average Score 0-1000) per subtest in selected month
    final hoursBySubtest = <String, double>{};
    for (final log in storage.dailyLogs) {
      if (_selectedQuadrantMonth != 'Semua' &&
          !log.date.startsWith(_selectedQuadrantMonth)) {
        continue;
      }
      hoursBySubtest[log.subtestCode] =
          (hoursBySubtest[log.subtestCode] ?? 0.0) + (log.minutes / 60.0);
    }

    final scoreSums = <String, double>{};
    final scoreCounts = <String, int>{};
    for (final t in storage.utbkTryouts) {
      if (_selectedQuadrantMonth != 'Semua' &&
          !t.date.startsWith(_selectedQuadrantMonth)) {
        continue;
      }
      t.subtestScores.forEach((sub, sc) {
        scoreSums[sub] = (scoreSums[sub] ?? 0.0) + sc;
        scoreCounts[sub] = (scoreCounts[sub] ?? 0) + 1;
      });
    }

    // Also include SKD subtests normalized to 1000 scale
    for (final skd in storage.skdTryouts) {
      if (_selectedQuadrantMonth != 'Semua' &&
          !skd.date.startsWith(_selectedQuadrantMonth)) {
        continue;
      }
      scoreSums['TWK'] = (scoreSums['TWK'] ?? 0) + (skd.twk / 150.0) * 1000.0;
      scoreCounts['TWK'] = (scoreCounts['TWK'] ?? 0) + 1;
      scoreSums['TIU'] = (scoreSums['TIU'] ?? 0) + (skd.tiu / 175.0) * 1000.0;
      scoreCounts['TIU'] = (scoreCounts['TIU'] ?? 0) + 1;
      scoreSums['TKP'] = (scoreSums['TKP'] ?? 0) + (skd.tkp / 225.0) * 1000.0;
      scoreCounts['TKP'] = (scoreCounts['TKP'] ?? 0) + 1;
    }

    final subtestCodes = <String>{
      ...scoreSums.keys,
      ...hoursBySubtest.keys,
    }.toList();

    // Median dividers: X = 3.0 hours, Y = 700 score
    const double medianX = 3.0;
    const double medianY = 700.0;
    const double maxX = 6.5;
    const double minY = 500.0;
    const double maxY = 900.0;

    final items = <(String, double, double, String, Color)>[];
    for (int i = 0; i < subtestCodes.length; i++) {
      final code = subtestCodes[i];
      final h = (hoursBySubtest[code] ?? (1.2 + (i % 4) * 1.1)).clamp(0.4, 6.2);
      final avgScore = scoreCounts.containsKey(code)
          ? (scoreSums[code]! / scoreCounts[code]!)
          : (storage.subtestAverages[code] ?? (615.0 + (i * 27) % 165));
      final clampedY = avgScore.clamp(minY + 15, maxY - 15);

      String quadrantName;
      Color quadrantColor;
      if (h >= medianX && clampedY >= medianY) {
        quadrantName = 'Kuadran I: Mastered / Pertahankan';
        quadrantColor = StriveColors.emerald;
      } else if (h < medianX && clampedY >= medianY) {
        quadrantName = 'Kuadran II: Bakat Alami';
        quadrantColor = StriveColors.sky;
      } else if (h < medianX && clampedY < medianY) {
        quadrantName = 'Kuadran III: Zona Bahaya / Kurang Latihan';
        quadrantColor = StriveColors.rose;
      } else {
        quadrantName = 'Kuadran IV: Evaluasi Metode Belajar';
        quadrantColor = StriveColors.amber;
      }
      items.add((code, h, clampedY, quadrantName, quadrantColor));
    }

    if (items.isEmpty) {
      items.addAll([
        ('PK', 4.8, 742, 'Kuadran I: Mastered / Pertahankan', StriveColors.emerald),
        ('LBI', 1.8, 755, 'Kuadran II: Bakat Alami', StriveColors.sky),
        ('KIM', 1.4, 635, 'Kuadran III: Zona Bahaya / Kurang Latihan', StriveColors.rose),
        ('PM', 4.5, 655, 'Kuadran IV: Evaluasi Metode Belajar', StriveColors.amber),
      ]);
    }

    final scatterSpots = items
        .map(
          (item) => ScatterSpot(
            item.$2,
            item.$3,
            dotPainter: FlDotCirclePainter(
              radius: 8,
              color: item.$5,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        )
        .toList();

    return Strive3DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_4x4_rounded, color: StriveColors.sky),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DIAGRAM KARTESIUS 2: 4-KUADRAN EFFORT VS SCORE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sumbu X: Jam Latihan Bulanan | Sumbu Y: Skor Rata-rata (Pembagi Median X=3.0 Jam, Y=700 Poin)',
            style: TextStyle(
              fontSize: 12,
              color: StriveColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _monthFilters.map((m) {
                final selected = _selectedQuadrantMonth == m.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      m.$2,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    selected: selected,
                    selectedColor: StriveColors.sky.withValues(alpha: 0.25),
                    onSelected: (_) =>
                        setState(() => _selectedQuadrantMonth = m.$1),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                // Underlying LineChart renders the exact HorizontalLine & VerticalLine median quadrant dividers
                LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    gridData: const FlGridData(show: false),
                    titlesData: _quadrantTitlesData(context),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: medianY,
                          color: Colors.white.withValues(alpha: 0.65),
                          strokeWidth: 2,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topLeft,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: StriveColors.sky,
                            ),
                            labelResolver: (_) => 'II: Bakat Alami',
                          ),
                        ),
                      ],
                      verticalLines: [
                        VerticalLine(
                          x: medianX,
                          color: Colors.white.withValues(alpha: 0.65),
                          strokeWidth: 2,
                          dashArray: [6, 4],
                          label: VerticalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: StriveColors.emerald,
                            ),
                            labelResolver: (_) => 'I: Mastered',
                          ),
                        ),
                      ],
                    ),
                    lineBarsData: const [],
                  ),
                ),
                // ScatterChart on top with identical coordinate bounds
                ScatterChart(
                  ScatterChartData(
                    minX: 0,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.15),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (_) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: _quadrantTitlesData(context),
                    scatterSpots: scatterSpots,
                    scatterTouchData: ScatterTouchData(
                      enabled: true,
                      touchTooltipData: ScatterTouchTooltipData(
                        getTooltipItems: (ScatterSpot touchedSpot) {
                          final found = items.firstWhere(
                            (e) =>
                                (e.$2 - touchedSpot.x).abs() < 0.01 &&
                                (e.$3 - touchedSpot.y).abs() < 0.01,
                            orElse: () => items.first,
                          );
                          return ScatterTooltipItem(
                            '${found.$1}\n${found.$2.toStringAsFixed(1)} Jam • Skor ${found.$3.toStringAsFixed(0)}\n${found.$4}',
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 4-Quadrant Legend & Subtest Mapping Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: item.$5.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: item.$5.withValues(alpha: 0.6)),
                ),
                child: Text(
                  '${item.$1} (${item.$2.toStringAsFixed(1)}j • ${item.$3.toStringAsFixed(0)}) → ${item.$4.split(":").first}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: item.$5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  FlTitlesData _quadrantTitlesData(BuildContext context) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 100,
          getTitlesWidget: (val, _) => Text(
            val.toInt().toString(),
            style: TextStyle(
              fontSize: 10.5,
              color: StriveColors.textSecondary(context),
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          interval: 1.5,
          getTitlesWidget: (val, _) => Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '${val.toStringAsFixed(1)}j',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadarAndGapAnalyzerCard(
    BuildContext context,
    StorageService storage,
  ) {
    final avgs = storage.subtestAverages;
    final targetUtbk = storage.profile?.targetUtbkScore ?? 745.0;

    final radarAxes = [
      ('PU', avgs['PU'] ?? 680.0),
      ('PK', avgs['PK'] ?? 665.0),
      ('PM', avgs['PM'] ?? 670.0),
      ('LBI', avgs['LBI'] ?? 715.0),
      ('LBE', avgs['LBE'] ?? 695.0),
      (
        'SKD',
        storage.latestSkdTotal > 0
            ? (storage.latestSkdTotal / 550.0) * 1000.0
            : 720.0
      ),
      (
        'FISIK',
        storage.latestSamaptaScore > 0
            ? storage.latestSamaptaScore * 10.0
            : 680.0
      ),
    ];

    // Sort deficits for Gap Analyzer
    final deficits = radarAxes
        .map((e) => (e.$1, e.$2, targetUtbk - e.$2))
        .toList()
      ..sort((a, b) => b.$3.compareTo(a.$3));

    return Strive3DCard(
      borderColor: StriveColors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.radar_rounded, color: StriveColors.purple),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MULTI-TRACK RADAR & DEFICIT GAP ANALYZER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4,
                ticksTextStyle: const TextStyle(
                  fontSize: 9,
                  color: Colors.transparent,
                ),
                radarBorderData: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                gridBorderData: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.25),
                  width: 1,
                ),
                tickBorderData: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                titlePositionPercentageOffset: 0.18,
                titleTextStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
                getTitle: (index, angle) {
                  return RadarChartTitle(text: radarAxes[index].$1);
                },
                dataSets: [
                  // Target Passing Polygon
                  RadarDataSet(
                    fillColor: StriveColors.amber.withValues(alpha: 0.08),
                    borderColor: StriveColors.amber,
                    borderWidth: 2,
                    entryRadius: 2,
                    dataEntries: List.generate(
                      radarAxes.length,
                      (_) => RadarEntry(value: targetUtbk),
                    ),
                  ),
                  // User Current Mastery Polygon
                  RadarDataSet(
                    fillColor: StriveColors.emerald.withValues(alpha: 0.25),
                    borderColor: StriveColors.emerald,
                    borderWidth: 3,
                    entryRadius: 4,
                    dataEntries: radarAxes
                        .map((e) => RadarEntry(value: e.$2.clamp(300, 1000)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            ' Prioritas Tambal Defisit (Gap Analyzer):',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          ...deficits.take(3).map((d) {
            final gap = d.$3;
            final isDeficit = gap > 0;
            final color = isDeficit ? StriveColors.rose : StriveColors.emerald;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtes ${d.$1} (Skor: ${d.$2.toStringAsFixed(0)})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      isDeficit
                          ? 'Defisit -${gap.toStringAsFixed(0)} pts'
                          : 'Surplus +${(-gap).toStringAsFixed(0)} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
