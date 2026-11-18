import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/passing_grades.dart';
import '../models/strive_models.dart';
import '../services/storage_service.dart';
import '../widgets/ignis_mascot_widget.dart';
import '../widgets/strive_3d_button.dart';
import '../widgets/strive_theme.dart';

class WorkoutTimerSheet extends StatefulWidget {
  final int initialTabIndex;
  const WorkoutTimerSheet({super.key, this.initialTabIndex = 0});

  @override
  State<WorkoutTimerSheet> createState() => _WorkoutTimerSheetState();
}

class _WorkoutTimerSheetState extends State<WorkoutTimerSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Academic Pomodoro State
  String _selectedTrack = 'UTBK';
  String _selectedSubtest = 'PK';
  int _pomodoroPresetMinutes = 25;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  final _manualMinutesCtrl = TextEditingController(text: '35');
  final _notesCtrl = TextEditingController();

  // Samapta Physical Timer State
  String _samaptaDrill = 'Pull-up / Chinning (60s)';
  int _samaptaDurationSec = 60;
  int _samaptaRemainingSec = 60;
  bool _samaptaRunning = false;
  int _liveRepOrMeterCount = 0;

  // Post-Session Fatigue Check-in
  String _fatigueLevel = 'Semangat';

  static const Map<String, List<String>> _subtestsByTrack = {
    'UTBK': ['PU', 'PPU', 'PBM', 'PK', 'LBI', 'LBE', 'PM'],
    'TKA': ['MTK_L', 'FIS', 'KIM', 'BIO', 'EKO', 'GEO', 'SOS', 'SEJ'],
    'KEDINASAN': ['TWK', 'TIU', 'TKP', 'Pauli/Kraepelin', 'Kecerdasan'],
    'FISIK': [
      'Lari 12 Menit',
      'Pull-up / Chinning',
      'Sit-up 60s',
      'Push-up 60s',
      'Shuttle Run 6x10m'
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    _tabController.dispose();
    _manualMinutesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _toggleAcademicTimer() {
    if (_isRunning) {
      _timer?.cancel();
      WakelockPlus.disable();
      setState(() => _isRunning = false);
      return;
    }
    WakelockPlus.enable();
    setState(() => _isRunning = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        WakelockPlus.disable();
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _manualMinutesCtrl.text = _pomodoroPresetMinutes.toString();
        });
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  void _resetAcademicTimer(int mins) {
    _timer?.cancel();
    WakelockPlus.disable();
    setState(() {
      _pomodoroPresetMinutes = mins;
      _remainingSeconds = mins * 60;
      _isRunning = false;
      _manualMinutesCtrl.text = mins.toString();
    });
  }

  void _selectSamaptaMode(String mode, int seconds) {
    _timer?.cancel();
    WakelockPlus.disable();
    setState(() {
      _samaptaDrill = mode;
      _samaptaDurationSec = seconds;
      _samaptaRemainingSec = seconds;
      _samaptaRunning = false;
      _liveRepOrMeterCount = 0;
    });
  }

  void _toggleSamaptaTimer() {
    if (_samaptaRunning) {
      _timer?.cancel();
      WakelockPlus.disable();
      setState(() => _samaptaRunning = false);
      return;
    }
    WakelockPlus.enable();
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
    setState(() => _samaptaRunning = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_samaptaRemainingSec <= 1) {
        timer.cancel();
        WakelockPlus.disable();
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
        setState(() {
          _samaptaRemainingSec = 0;
          _samaptaRunning = false;
        });
      } else {
        setState(() => _samaptaRemainingSec -= 1);
        // Audio/haptic beep on final 5 seconds or every 60s on Cooper run
        if (_samaptaRemainingSec <= 5 || _samaptaRemainingSec % 60 == 0) {
          HapticFeedback.mediumImpact();
          SystemSound.play(SystemSoundType.click);
        }
      }
    });
  }

  String _formatClock(int totalSec) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _submitCheckIn({required bool isSamapta}) async {
    final storage = context.read<StorageService>();
    final mins = isSamapta
        ? (_samaptaDurationSec == 720 ? 25 : 15)
        : (int.tryParse(_manualMinutesCtrl.text.trim()) ??
            _pomodoroPresetMinutes);

    final track = isSamapta ? 'FISIK' : _selectedTrack;
    final subtest = isSamapta ? _samaptaDrill : _selectedSubtest;
    final notes = isSamapta
        ? '$_samaptaDrill: $_liveRepOrMeterCount ${_samaptaDurationSec == 720 ? "meter" : "repetisi"}'
        : _notesCtrl.text.trim();

    await storage.logStudyOrWorkoutSession(
      track: track,
      subtestCode: subtest,
      minutes: mins.clamp(5, 300),
      fatigueLevel: _fatigueLevel,
      notes: notes,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: StriveColors.emerald,
        content: Text(
          '🔥 Streak +1! Sesi $subtest ($mins mnt) tercatat. +${(mins * 3).clamp(15, 300)} EXP & +${(mins * 2).clamp(10, 200)} Koin!',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final gender = storage.profile?.gender ?? 'Pria';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: StriveColors.background(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_rounded,
                  color: StriveColors.emerald,
                  size: 26,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'MARKAS LATIHAN HARIAN & STOPWATCH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              indicatorColor: StriveColors.emerald,
              labelColor: StriveColors.emerald,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.menu_book_rounded),
                  text: 'Pomodoro Akademik',
                ),
                Tab(
                  icon: Icon(Icons.fitness_center_rounded),
                  text: 'Stopwatch Samapta',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAcademicTab(context),
                _buildSamaptaStopwatchTab(context, gender),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicTab(BuildContext context) {
    final subtests = _subtestsByTrack[_selectedTrack] ?? ['PK'];
    if (!subtests.contains(_selectedSubtest)) {
      _selectedSubtest = subtests.first;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pomodoro Digital Clock Card
          Strive3DCard(
            borderColor: StriveColors.emerald,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final preset in [15, 25, 50])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text('$preset Menit'),
                          selected: _pomodoroPresetMinutes == preset,
                          onSelected: (_) => _resetAcademicTimer(preset),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _formatClock(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: StriveColors.emerald,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isRunning
                      ? '🔥 Wakelock Aktif • Fokus penuh tanpa terdistraksi!'
                      : 'Siap mulai sesi fokus $_selectedSubtest',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: StriveColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Strive3DButton(
                        color: _isRunning
                            ? StriveColors.amber
                            : StriveColors.emerald,
                        onPressed: _toggleAcademicTimer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                            const SizedBox(width: 6),
                            Text(_isRunning ? 'JEDA SESI' : 'MULAI POMODORO'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Strive3DButton(
                      color: Colors.blueGrey.shade700,
                      onPressed: () =>
                          _resetAcademicTimer(_pomodoroPresetMinutes),
                      child: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Pilih Jalur & Subtes yang Dipelajari:',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['UTBK', 'TKA', 'KEDINASAN', 'FISIK'].map((trk) {
              final active = _selectedTrack == trk;
              return ChoiceChip(
                label: Text(
                  trk,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                selected: active,
                selectedColor: StriveColors.indigo.withValues(alpha: 0.25),
                onSelected: (_) {
                  setState(() {
                    _selectedTrack = trk;
                    _selectedSubtest = _subtestsByTrack[trk]!.first;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subtests.map((sub) {
              final active = _selectedSubtest == sub;
              return ChoiceChip(
                label: Text(sub),
                selected: active,
                selectedColor: StriveColors.emerald.withValues(alpha: 0.25),
                onSelected: (_) => setState(() => _selectedSubtest = sub),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualMinutesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Durasi Belajar (Menit)',
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Materi (Opsional)',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFatigueCheckInSection(context),
          const SizedBox(height: 16),
          Strive3DButton(
            fullWidth: true,
            color: StriveColors.emerald,
            onPressed: () => _submitCheckIn(isSamapta: false),
            child: const Text(
              '✅ SIMPAN SESI & KLAIM STREAK + EXP',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSamaptaStopwatchTab(BuildContext context, String gender) {
    final isCooper = _samaptaDurationSec == 720;
    final liveScore = isCooper
        ? SamaptaCalculator.scoreLari12Menit(
            _liveRepOrMeterCount.toDouble(),
            gender,
          )
        : (_samaptaDrill.contains('Pull')
            ? SamaptaCalculator.scorePullUpOrChinning(
                _liveRepOrMeterCount,
                gender,
              )
            : SamaptaCalculator.scorePushUp(_liveRepOrMeterCount, gender));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IgnisMascotWidget(
            mood: IgnisMood.coachSpartan,
            speechText: isCooper
                ? 'Cooper Test 12 Menit ($gender): Jaga ritme napas 2-2, jangan sprint di menit pertama! Target aman >= ${gender == "Wanita" ? "2100m" : "2400m"}!'
                : 'Timer 60 Detik Haptic Beep siap! Setiap repetisi harus Full Range of Motion (ROM) agar dihitung penguji Samapta!',
            size: 80,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(
                  gender == 'Wanita' ? 'Chinning 60s' : 'Pull-up 60s',
                ),
                selected: _samaptaDrill.contains('Pull'),
                onSelected: (_) =>
                    _selectSamaptaMode('Pull-up / Chinning (60s)', 60),
              ),
              ChoiceChip(
                label: const Text('Sit-up 60s'),
                selected: _samaptaDrill.contains('Sit-up'),
                onSelected: (_) => _selectSamaptaMode('Sit-up (60s)', 60),
              ),
              ChoiceChip(
                label: const Text('Push-up 60s'),
                selected: _samaptaDrill.contains('Push-up'),
                onSelected: (_) => _selectSamaptaMode('Push-up (60s)', 60),
              ),
              ChoiceChip(
                label: const Text('Lari Cooper 12 Menit'),
                selected: isCooper,
                onSelected: (_) =>
                    _selectSamaptaMode('Lari Cooper 12 Menit', 720),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Strive3DCard(
            borderColor: StriveColors.amber,
            child: Column(
              children: [
                Text(
                  _samaptaDrill.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: StriveColors.amber,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatClock(_samaptaRemainingSec),
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: StriveColors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          isCooper ? 'JARAK TEMPUH' : 'TOTAL REPETISI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: StriveColors.textSecondary(context),
                          ),
                        ),
                        Text(
                          isCooper
                              ? '$_liveRepOrMeterCount m'
                              : '${_liveRepOrMeterCount}x',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'ESTIMASI SKOR SAMAPTA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: StriveColors.textSecondary(context),
                          ),
                        ),
                        Text(
                          liveScore.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: liveScore >= 70
                                ? StriveColors.emerald
                                : StriveColors.rose,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Strive3DButton(
                      color: StriveColors.indigo,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      onPressed: () {
                        setState(() {
                          _liveRepOrMeterCount += isCooper ? 100 : 1;
                        });
                      },
                      child: Text(isCooper ? '+100 Meter' : '+1 Rep'),
                    ),
                    const SizedBox(width: 10),
                    Strive3DButton(
                      color: StriveColors.sky,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      onPressed: () {
                        setState(() {
                          _liveRepOrMeterCount += isCooper ? 400 : 5;
                        });
                      },
                      child: Text(isCooper ? '+400m (1 Lap)' : '+5 Reps'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Strive3DButton(
                        color: _samaptaRunning
                            ? StriveColors.rose
                            : StriveColors.amber,
                        onPressed: _toggleSamaptaTimer,
                        child: Text(
                          _samaptaRunning
                              ? 'HENTIKAN TIMER'
                              : 'MULAI COUNTDOWN + BEEP',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Strive3DButton(
                      color: Colors.blueGrey.shade700,
                      onPressed: () =>
                          _selectSamaptaMode(_samaptaDrill, _samaptaDurationSec),
                      child: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildFatigueCheckInSection(context),
          const SizedBox(height: 14),
          Strive3DButton(
            fullWidth: true,
            color: StriveColors.emerald,
            onPressed: () => _submitCheckIn(isSamapta: true),
            child: const Text(
              '💪 CATAT WORKOUT SAMAPTA & NAIKKAN STREAK',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFatigueCheckInSection(BuildContext context) {
    final options = [
      ('Semangat', '🔥 Semangat', StriveColors.emerald),
      ('Biasa', '⚡ Biasa', StriveColors.amber),
      ('Otak/Badan Ngebul', '🤯 Otak/Badan Ngebul', StriveColors.rose),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Post-Session Check-in (Kondisi Mental & Fisik):',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final selected = _fatigueLevel == opt.$1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Strive3DButton(
                  color: selected ? opt.$3 : Colors.blueGrey.shade800,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  onPressed: () => setState(() => _fatigueLevel = opt.$1),
                  child: Text(
                    opt.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
