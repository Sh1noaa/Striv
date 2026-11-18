import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/passing_grades.dart';
import '../models/strive_models.dart';
import '../services/storage_service.dart';
import '../widgets/ignis_mascot_widget.dart';
import '../widgets/strive_3d_button.dart';
import '../widgets/strive_theme.dart';

class TryoutSamaptaTabScreen extends StatefulWidget {
  const TryoutSamaptaTabScreen({super.key});

  @override
  State<TryoutSamaptaTabScreen> createState() => _TryoutSamaptaTabScreenState();
}

class _TryoutSamaptaTabScreenState extends State<TryoutSamaptaTabScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Segment 1: UTBK & TKA Logger Controllers
  String _tryoutCategory = 'UTBK'; // 'UTBK' or 'TKA'
  final _toNameCtrl = TextEditingController(text: 'TryOut SNBT Ep. 6');
  final Map<String, TextEditingController> _subtestCtrls = {};

  // Segment 2: SKD & Psikotes Controllers
  final _skdNameCtrl = TextEditingController(text: 'Simulasi SKD CAT BKN');
  final _twkCtrl = TextEditingController(text: '95');
  final _tiuCtrl = TextEditingController(text: '140');
  final _tkpCtrl = TextEditingController(text: '192');

  final _psiNameCtrl = TextEditingController(text: 'Simulasi Pauli & Spasial');
  final _psiCerdasCtrl = TextEditingController(text: '82');
  final _psiPribadiCtrl = TextEditingController(text: '85');
  final _psiSpeedCtrl = TextEditingController(text: '80');
  final _psiAccCtrl = TextEditingController(text: '94');
  final _psiStabCtrl = TextEditingController(text: '86');

  // Segment 3: Samapta Physical Calculator Controllers
  final _lariCtrl = TextEditingController(text: '1950');
  final _pullChinCtrl = TextEditingController(text: '3');
  final _sitUpCtrl = TextEditingController(text: '28');
  final _pushUpCtrl = TextEditingController(text: '26');
  final _shuttleCtrl = TextEditingController(text: '18.6');
  final _renangCtrl = TextEditingController(text: '29.0');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final allCodes = [
      ...PassingGradesRepository.utbkSubtests.map((e) => e.code),
      ...PassingGradesRepository.tkaSaintekSubtests.map((e) => e.code),
      ...PassingGradesRepository.tkaSoshumSubtests.map((e) => e.code),
      'CUSTOM',
    ];
    for (final code in allCodes) {
      _subtestCtrls[code] = TextEditingController(text: '710');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _toNameCtrl.dispose();
    for (final c in _subtestCtrls.values) {
      c.dispose();
    }
    _skdNameCtrl.dispose();
    _twkCtrl.dispose();
    _tiuCtrl.dispose();
    _tkpCtrl.dispose();
    _psiNameCtrl.dispose();
    _psiCerdasCtrl.dispose();
    _psiPribadiCtrl.dispose();
    _psiSpeedCtrl.dispose();
    _psiAccCtrl.dispose();
    _psiStabCtrl.dispose();
    _lariCtrl.dispose();
    _pullChinCtrl.dispose();
    _sitUpCtrl.dispose();
    _pushUpCtrl.dispose();
    _shuttleCtrl.dispose();
    _renangCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? StriveColors.darkSurface
              : StriveColors.lightSurface,
          child: TabBar(
            controller: _tabController,
            indicatorColor: StriveColors.emerald,
            labelColor: StriveColors.emerald,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
            tabs: const [
              Tab(text: '1. UTBK & TKA'),
              Tab(text: '2. SKD & Psikotes'),
              Tab(text: '3. Fisik Samapta'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUtbkTkaTab(context),
              _buildSkdPsikotesTab(context),
              _buildSamaptaCoachTab(context),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SEGMENT 1: UTBK & TKA LOGGER WITH DELTA CHIPS
  // =========================================================================
  Widget _buildUtbkTkaTab(BuildContext context) {
    final storage = context.watch<StorageService>();
    final tkaType = storage.profile?.tkaCategory ?? 'Saintek';
    final customTka = storage.profile?.customTkaSubtest ?? '';

    final activeCodes = _tryoutCategory == 'UTBK'
        ? PassingGradesRepository.utbkSubtests.map((e) => e.code).toList()
        : [
            ...(tkaType == 'Soshum'
                    ? PassingGradesRepository.tkaSoshumSubtests
                    : PassingGradesRepository.tkaSaintekSubtests)
                .map((e) => e.code),
            if (customTka.isNotEmpty) customTka,
          ];

    for (final c in activeCodes) {
      _subtestCtrls.putIfAbsent(c, () => TextEditingController(text: '700'));
    }

    final filteredHistory = storage.utbkTryouts
        .where((e) => e.category == _tryoutCategory)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Strive3DButton(
                  color: _tryoutCategory == 'UTBK'
                      ? StriveColors.emerald
                      : Colors.blueGrey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  onPressed: () => setState(() {
                    _tryoutCategory = 'UTBK';
                    _toNameCtrl.text =
                        'TryOut SNBT Ep. ${storage.utbkTryouts.length + 1}';
                  }),
                  child: const Text('LOG UTBK-SNBT (7 Subtes)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Strive3DButton(
                  color: _tryoutCategory == 'TKA'
                      ? StriveColors.indigo
                      : Colors.blueGrey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  onPressed: () => setState(() {
                    _tryoutCategory = 'TKA';
                    _toNameCtrl.text = 'Simulasi TKA $tkaType';
                  }),
                  child: Text('LOG TKA ($tkaType)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Strive3DCard(
            borderColor: _tryoutCategory == 'UTBK'
                ? StriveColors.emerald
                : StriveColors.indigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INPUT SKOR TRYOUT $_tryoutCategory (SKALA 0–1000)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _toNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama TryOut / Penyelenggara',
                    prefixIcon: Icon(Icons.assignment_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: activeCodes.map((code) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 78) / 2,
                      child: TextField(
                        controller: _subtestCtrls[code],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Subtes $code',
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Strive3DButton(
                  fullWidth: true,
                  color: _tryoutCategory == 'UTBK'
                      ? StriveColors.emerald
                      : StriveColors.indigo,
                  onPressed: () async {
                    final scores = <String, double>{};
                    for (final code in activeCodes) {
                      final val = double.tryParse(
                              _subtestCtrls[code]?.text.trim() ?? '0') ??
                          0.0;
                      scores[code] = val.clamp(0.0, 1000.0);
                    }
                    final tryout = UtbkTkaTryout(
                      id: 'to-${DateTime.now().millisecondsSinceEpoch}',
                      name: _toNameCtrl.text.trim().isEmpty
                          ? 'TryOut $_tryoutCategory'
                          : _toNameCtrl.text.trim(),
                      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      category: _tryoutCategory,
                      subtestScores: scores,
                    );
                    await storage.addUtbkTkaTryout(tryout);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: StriveColors.emerald,
                          content: Text(
                            '🔥 TryOut ${tryout.name} (Rata-rata: ${tryout.averageScore.toStringAsFixed(1)}) tersimpan!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('SIMPAN TRYOUT $_tryoutCategory (+120 EXP)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'RIWAYAT TRYOUT $_tryoutCategory & DELTA PROGRES',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 10),
          if (filteredHistory.isEmpty)
            const IgnisMascotWidget(
              mood: IgnisMood.happyHype,
              speechText:
                  'Belum ada riwayat TryOut di kategori ini. Yuk log skor TryOut pertamamu di atas!',
              size: 80,
            )
          else
            ...List.generate(filteredHistory.length, (index) {
              final current = filteredHistory[index];
              final prev = index + 1 < filteredHistory.length
                  ? filteredHistory[index + 1]
                  : null;
              final delta =
                  prev != null ? (current.averageScore - prev.averageScore) : 0.0;
              final isPositive = delta >= 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Strive3DCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.5,
                                  ),
                                ),
                                Text(
                                  current.date,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: StriveColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (prev != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (isPositive
                                        ? StriveColors.emerald
                                        : StriveColors.rose)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${isPositive ? "+" : ""}${delta.toStringAsFixed(0)} pts',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: isPositive
                                      ? StriveColors.emerald
                                      : StriveColors.rose,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  StriveColors.indigo.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              current.averageScore.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: StriveColors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: current.subtestScores.entries.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: StriveColors.background(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: StriveColors.border(context),
                              ),
                            ),
                            child: Text(
                              '${e.key}: ${e.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        }).toList(),
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

  // =========================================================================
  // SEGMENT 2: SKD CAT BKN & PSIKOTES KEDINASAN LOGGER
  // =========================================================================
  Widget _buildSkdPsikotesTab(BuildContext context) {
    final storage = context.watch<StorageService>();
    final twk = int.tryParse(_twkCtrl.text.trim()) ?? 0;
    final tiu = int.tryParse(_tiuCtrl.text.trim()) ?? 0;
    final tkp = int.tryParse(_tkpCtrl.text.trim()) ?? 0;
    final liveTotal = twk + tiu + tkp;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SKD Logger Card
          Strive3DCard(
            borderColor: StriveColors.amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LOGGER SKD CAT BKN (MAX 550)',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (twk >= 65 && tiu >= 80 && tkp >= 166
                                ? StriveColors.emerald
                                : StriveColors.rose)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'TOTAL: $liveTotal / 550',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: twk >= 65 && tiu >= 80 && tkp >= 166
                              ? StriveColors.emerald
                              : StriveColors.rose,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _skdNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Simulasi SKD CAT',
                    prefixIcon: Icon(Icons.military_tech_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _twkCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'TWK (>=65)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _tiuCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'TIU (>=80)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _tkpCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'TKP (>=166)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ambangBatasBadge('TWK', twk, 65),
                    _ambangBatasBadge('TIU', tiu, 80),
                    _ambangBatasBadge('TKP', tkp, 166),
                  ],
                ),
                const SizedBox(height: 12),
                Strive3DButton(
                  fullWidth: true,
                  color: StriveColors.amber,
                  onPressed: () async {
                    final skd = SkdTryout(
                      id: 'skd-${DateTime.now().millisecondsSinceEpoch}',
                      name: _skdNameCtrl.text.trim().isEmpty
                          ? 'Simulasi SKD CAT'
                          : _skdNameCtrl.text.trim(),
                      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      twk: twk.clamp(0, 150),
                      tiu: tiu.clamp(0, 175),
                      tkp: tkp.clamp(0, 225),
                    );
                    await storage.addSkdTryout(skd);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: skd.passedAll
                              ? StriveColors.emerald
                              : StriveColors.rose,
                          content: Text(
                            skd.passedAll
                                ? '🏆 SKD ${skd.totalScore}/550 LULUS AMBANG BATAS!'
                                : '⚠️ SKD ${skd.totalScore}/550 GUGUR AMBANG BATAS! Ignis marah!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('SIMPAN SKOR SKD CAT'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Psikotes Kedinasan Logger (Kecerdasan, Kepribadian, Kecermatan Pauli/Kraepelin)
          Strive3DCard(
            borderColor: StriveColors.sky,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOGGER PSIKOTES & KECERMATAN (PAULI / KRAEPELIN)',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _psiNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Paket Psikotes',
                    prefixIcon: Icon(Icons.psychology_alt_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _psiCerdasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kecerdasan (0-100)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _psiPribadiCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kepribadian (0-100)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _psiSpeedCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Speed Pauli',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _psiAccCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Akurasi (%)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _psiStabCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stabilitas',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Strive3DButton(
                  fullWidth: true,
                  color: StriveColors.sky,
                  onPressed: () async {
                    final log = PsikotesLog(
                      id: 'psi-${DateTime.now().millisecondsSinceEpoch}',
                      name: _psiNameCtrl.text.trim().isEmpty
                          ? 'Simulasi Psikotes'
                          : _psiNameCtrl.text.trim(),
                      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      kecerdasan:
                          double.tryParse(_psiCerdasCtrl.text.trim()) ?? 80,
                      kepribadian:
                          double.tryParse(_psiPribadiCtrl.text.trim()) ?? 80,
                      kecermatanSpeed:
                          double.tryParse(_psiSpeedCtrl.text.trim()) ?? 78,
                      kecermatanAccuracy:
                          double.tryParse(_psiAccCtrl.text.trim()) ?? 92,
                      kecermatanStability:
                          double.tryParse(_psiStabCtrl.text.trim()) ?? 84,
                    );
                    await storage.addPsikotesLog(log);
                  },
                  child: const Text('SIMPAN HASIL PSIKOTES & KECERMATAN'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'RIWAYAT SKD CAT & STATUS AMBANG BATAS',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...storage.skdTryouts.map((skd) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Strive3DCard(
                borderColor:
                    skd.passedAll ? StriveColors.emerald : StriveColors.rose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${skd.name} (${skd.date})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (skd.passedAll
                                    ? StriveColors.emerald
                                    : StriveColors.rose)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            skd.passedAll
                                ? 'LULUS AMBANG BATAS (${skd.totalScore})'
                                : 'GUGUR / NILAI MATI (${skd.totalScore})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: skd.passedAll
                                  ? StriveColors.emerald
                                  : StriveColors.rose,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _ambangBatasBadge('TWK', skd.twk, 65),
                        _ambangBatasBadge('TIU', skd.tiu, 80),
                        _ambangBatasBadge('TKP', skd.tkp, 166),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          if (storage.psikotesLogs.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'RIWAYAT PSIKOTES & PAULI/KRAEPELIN',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...storage.psikotesLogs.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Strive3DCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              'Cerdas: ${p.kecerdasan.toInt()} • Pribadi: ${p.kepribadian.toInt()} • Pauli Speed ${p.kecermatanSpeed.toInt()} / Akurasi ${p.kecermatanAccuracy.toInt()}%',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: StriveColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        p.overallScore.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: StriveColors.sky,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _ambangBatasBadge(String label, int score, int passing) {
    final passed = score >= passing;
    final col = passed ? StriveColors.emerald : StriveColors.rose;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: col.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label: $score ($passing) • ${passed ? "LULUS AMBANG BATAS" : "GUGUR (NILAI MATI)"}',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: col,
        ),
      ),
    );
  }

  // =========================================================================
  // SEGMENT 3: TES FISIK / SAMAPTA CALCULATOR & IGNIS AI COACH
  // =========================================================================
  Widget _buildSamaptaCoachTab(BuildContext context) {
    final storage = context.watch<StorageService>();
    final gender = storage.profile?.gender ?? 'Pria';
    final isWanita = gender.toLowerCase() == 'wanita';

    final lariMeters = double.tryParse(_lariCtrl.text.trim()) ?? 1950.0;
    final pullChinReps = int.tryParse(_pullChinCtrl.text.trim()) ?? 3;
    final sitUpReps = int.tryParse(_sitUpCtrl.text.trim()) ?? 28;
    final pushUpReps = int.tryParse(_pushUpCtrl.text.trim()) ?? 26;
    final shuttleSec = double.tryParse(_shuttleCtrl.text.trim()) ?? 18.6;
    final renangSec = double.tryParse(_renangCtrl.text.trim()) ?? 29.0;

    final previewLog = SamaptaCalculator.createCalculatedLog(
      id: 'preview',
      date: storage.todayDateString,
      gender: gender,
      lari12MenitMeters: lariMeters,
      pullUpOrChinningReps: pullChinReps,
      sitUpReps: sitUpReps,
      pushUpReps: pushUpReps,
      shuttleRunSeconds: shuttleSec,
      renang25mSeconds: renangSec,
    );

    final prescriptions = SamaptaCalculator.diagnoseAndPrescribe(
      gender: gender,
      lariMeters: lariMeters,
      pullOrChinReps: pullChinReps,
      sitUpReps: sitUpReps,
      pushUpReps: pushUpReps,
      shuttleSeconds: shuttleSec,
    );

    final weakItem = prescriptions.firstWhere(
      (p) => p.statusZone == 'Zona Bahaya',
      orElse: () => prescriptions.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ignis Spartan Coach Header Banner
          IgnisMascotWidget(
            mood: IgnisMood.coachSpartan,
            equippedAccessory: 'headband_spartan',
            speechText:
                'SKOR SAMAPTA: ${previewLog.finalScore.toStringAsFixed(1)}/100 ($gender). ${weakItem.deficitText}',
            size: 92,
          ),
          const SizedBox(height: 12),

          // Quick Preset Scenario Buttons + Gender Toggle
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: Text('Tabel: $gender (Ketuk Ubah)'),
                  onPressed: () {
                    final currentProfile = storage.profile;
                    if (currentProfile != null) {
                      storage.saveProfile(
                        currentProfile.copyWith(
                          gender: isWanita ? 'Pria' : 'Wanita',
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Preset: Pull-up 3x & Lari 1950m'),
                  onPressed: () {
                    setState(() {
                      _lariCtrl.text = '1950';
                      _pullChinCtrl.text = '3';
                      _sitUpCtrl.text = '25';
                      _pushUpCtrl.text = '24';
                      _shuttleCtrl.text = '18.8';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Preset: Taruna Elite 85+'),
                  onPressed: () {
                    setState(() {
                      _lariCtrl.text = isWanita ? '2480' : '2950';
                      _pullChinCtrl.text = isWanita ? '54' : '15';
                      _sitUpCtrl.text = '39';
                      _pushUpCtrl.text = isWanita ? '34' : '40';
                      _shuttleCtrl.text = isWanita ? '17.6' : '16.3';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Samapta A & B Live Calculator Card
          Strive3DCard(
            borderColor: previewLog.finalScore >= 70
                ? StriveColors.emerald
                : StriveColors.rose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'KALKULATOR SAMAPTA A & B (${gender.toUpperCase()})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: (previewLog.finalScore >= 70
                                ? StriveColors.emerald
                                : StriveColors.rose)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'SKOR AKHIR: ${previewLog.finalScore.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: previewLog.finalScore >= 70
                              ? StriveColors.emerald
                              : StriveColors.rose,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lariCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'A: Lari 12 Menit (m)',
                          helperText:
                              'Skor A: ${previewLog.scoreA.toStringAsFixed(0)}/100',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _pullChinCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: isWanita
                              ? 'B1: Chinning (1 mnt)'
                              : 'B1: Pull-up (1 mnt)',
                          helperText:
                              'Skor B1: ${previewLog.scoreB1.toStringAsFixed(0)}/100',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sitUpCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'B2: Sit-up (1 mnt)',
                          helperText:
                              'Skor B2: ${previewLog.scoreB2.toStringAsFixed(0)}/100',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _pushUpCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'B3: Push-up (1 mnt)',
                          helperText:
                              'Skor B3: ${previewLog.scoreB3.toStringAsFixed(0)}/100',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _shuttleCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'B4: Shuttle Run 6x10m (dtk)',
                          helperText:
                              'Skor B4: ${previewLog.scoreB4.toStringAsFixed(0)}/100',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _renangCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Renang 25m (dtk)',
                          helperText:
                              renangSec <= 35 ? 'Status: LULUS' : 'Perlu Latihan',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rumus Resmi: (Skor A [${previewLog.scoreA.toStringAsFixed(1)}] + Rata-rata B [${((previewLog.scoreB1 + previewLog.scoreB2 + previewLog.scoreB3 + previewLog.scoreB4) / 4).toStringAsFixed(1)}]) / 2 = ${previewLog.finalScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: StriveColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Strive3DButton(
                  fullWidth: true,
                  color: StriveColors.emerald,
                  onPressed: () async {
                    final saved = SamaptaCalculator.createCalculatedLog(
                      id: 'sam-${DateTime.now().millisecondsSinceEpoch}',
                      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      gender: gender,
                      lari12MenitMeters: lariMeters,
                      pullUpOrChinningReps: pullChinReps,
                      sitUpReps: sitUpReps,
                      pushUpReps: pushUpReps,
                      shuttleRunSeconds: shuttleSec,
                      renang25mSeconds: renangSec,
                    );
                    await storage.addSamaptaLog(saved);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: StriveColors.emerald,
                          content: Text(
                            '💪 Tes Samapta (Skor Akhir: ${saved.finalScore}) berhasil disimpan! +130 EXP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('SIMPAN HASIL TES SAMAPTA (+130 EXP)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. IGNIS AI COACH DIAGNOSTIC & PROGRESSIVE OVERLOAD PRESCRIPTION
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: StriveColors.amber),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'IGNIS AI COACH: DIAGNOSIS & RESEP PROGRESSIVE OVERLOAD',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...prescriptions.map((p) {
            final isDanger = p.statusZone == 'Zona Bahaya';
            final isWarn = p.statusZone == 'Zona Waspada';
            final col = isDanger
                ? StriveColors.rose
                : (isWarn ? StriveColors.amber : StriveColors.emerald);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Strive3DCard(
                borderColor: col,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p.itemTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '${p.statusZone} • ${p.currentScore.toStringAsFixed(0)} pts',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: col,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.deficitText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: col,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: StriveColors.background(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: StriveColors.border(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📋 Resep Drill Mingguan (Progressive Overload):',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: StriveColors.amber,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.weeklyDrill,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
