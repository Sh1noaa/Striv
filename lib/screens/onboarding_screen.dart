import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/passing_grades.dart';
import '../models/strive_models.dart';
import '../services/storage_service.dart';
import '../widgets/ignis_mascot_widget.dart';
import '../widgets/strive_3d_button.dart';
import '../widgets/strive_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  // Step 1: Identity
  final _nicknameCtrl = TextEditingController(text: 'Komandan Arya');
  final _schoolCtrl = TextEditingController(text: 'Kelas 12 SMA');
  String _gender = 'Pria';

  // Step 2: Multi-Track Selection
  final Set<String> _selectedTracks = {'UTBK', 'TKA', 'KEDINASAN'};
  String _tkaCategory = 'Saintek';
  final _customTkaCtrl = TextEditingController();

  // Step 3: Target Kampus & Passing Grade
  late InstitutionData _selectedPtn;
  late MajorPassingGrade _selectedPtnMajor;
  final _customPtnNameCtrl = TextEditingController();
  final _customPtnMajorCtrl = TextEditingController();
  final _targetUtbkScoreCtrl = TextEditingController();
  bool _useCustomPtn = false;

  late InstitutionData _selectedKedinasan;
  late MajorPassingGrade _selectedKedinasanMajor;
  final _targetSkdScoreCtrl = TextEditingController();
  final _targetSamaptaCtrl = TextEditingController(text: '75');

  // Step 4: Time Capsule
  final _timeCapsuleCtrl = TextEditingController(
    text:
        'Untuk diriku di Mei 2027:\nHari ini aku memulai perjalanan di Strive. Setiap soal PK, PM, TIU yang kubedah dan setiap repetisi Pull-up & Lari 12 menit adalah tiketku menuju kampus impian. Sampai jumpa di hari pengumuman kelulusan!',
  );

  @override
  void initState() {
    super.initState();
    _selectedPtn = PassingGradesRepository.ptnList.first;
    _selectedPtnMajor = _selectedPtn.majors.first;
    _targetUtbkScoreCtrl.text = _selectedPtnMajor.targetScore.toString();

    _selectedKedinasan = PassingGradesRepository.kedinasanList.first;
    _selectedKedinasanMajor = _selectedKedinasan.majors.first;
    _targetSkdScoreCtrl.text = _selectedKedinasanMajor.targetScore.toString();
    _targetSamaptaCtrl.text =
        _selectedKedinasanMajor.targetSamapta.toInt().toString();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _schoolCtrl.dispose();
    _customTkaCtrl.dispose();
    _customPtnNameCtrl.dispose();
    _customPtnMajorCtrl.dispose();
    _targetUtbkScoreCtrl.dispose();
    _targetSkdScoreCtrl.dispose();
    _targetSamaptaCtrl.dispose();
    _timeCapsuleCtrl.dispose();
    super.dispose();
  }

  String _stepSpeech() {
    switch (_step) {
      case 0:
        return 'Halo Pejuang 2027! Aku IGNIS, maskot penjaga disiplinmu. Kenalan dulu yuk—gender wajib dipilih untuk menyesuaikan tabel skor Samapta (Pull-up vs Chinning)!';
      case 1:
        return 'Pilih jalur tempurmu! Kamu bisa ambil UTBK-SNBT, TKA Saintek/Soshum, sekaligus Sekolah Kedinasan (SKD + Psikotes + Samapta)!';
      case 2:
        return 'Tentukan Boss Kampus PTN & Sekolah Kedinasan incaranmu! Passing grade otomatis terisi dan bebas kamu kustomisasi.';
      case 3:
      default:
        return 'Terakhir! Tulis Surat Kapsul Waktu untuk dirimu sendiri. Surat ini akan dikunci rapat di perangkatmu sampai Mei 2027!';
    }
  }

  IgnisMood _stepMood() {
    switch (_step) {
      case 0:
        return IgnisMood.happyHype;
      case 1:
        return IgnisMood.coachSpartan;
      case 2:
        return IgnisMood.happyHype;
      case 3:
      default:
        return IgnisMood.happyHype;
    }
  }

  Future<void> _finishOnboarding() async {
    final storage = context.read<StorageService>();
    final ptnName = _useCustomPtn && _customPtnNameCtrl.text.trim().isNotEmpty
        ? _customPtnNameCtrl.text.trim()
        : _selectedPtn.name;
    final ptnMajor = _useCustomPtn && _customPtnMajorCtrl.text.trim().isNotEmpty
        ? _customPtnMajorCtrl.text.trim()
        : _selectedPtnMajor.name;

    final profile = UserProfile(
      nickname: _nicknameCtrl.text.trim().isEmpty
          ? 'Komandan'
          : _nicknameCtrl.text.trim(),
      schoolGrade: _schoolCtrl.text.trim().isEmpty
          ? 'Kelas 12 SMA'
          : _schoolCtrl.text.trim(),
      gender: _gender,
      selectedTracks: _selectedTracks.isEmpty
          ? ['UTBK', 'TKA', 'KEDINASAN']
          : _selectedTracks.toList(),
      tkaCategory: _tkaCategory,
      customTkaSubtest: _customTkaCtrl.text.trim(),
      targetPtnId: _useCustomPtn ? 'custom' : _selectedPtn.id,
      targetPtnName: ptnName,
      targetPtnMajor: ptnMajor,
      targetUtbkScore:
          double.tryParse(_targetUtbkScoreCtrl.text.trim()) ?? 720.0,
      targetKedinasanId: _selectedKedinasan.id,
      targetKedinasanName: _selectedKedinasan.name,
      targetKedinasanMajor: _selectedKedinasanMajor.name,
      targetSkdScore: int.tryParse(_targetSkdScoreCtrl.text.trim()) ?? 445,
      targetSamaptaScore:
          double.tryParse(_targetSamaptaCtrl.text.trim()) ?? 75.0,
      timeCapsuleLetter: _timeCapsuleCtrl.text.trim(),
      timeCapsuleUnlockDate: '2027-05-01',
      createdAt: DateTime.now().toIso8601String(),
    );

    await storage.saveProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / 4.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Duolingo-Evolved Top Progress Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      onPressed: () => setState(() => _step -= 1),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: StriveColors.amber,
                      size: 28,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 14,
                        backgroundColor: isDark
                            ? StriveColors.darkBorder
                            : StriveColors.lightBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          StriveColors.emerald,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_step + 1}/4',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: StriveColors.emerald,
                    ),
                  ),
                ],
              ),
            ),

            // Ignis Mascot Guided Speech Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: IgnisMascotWidget(
                mood: _stepMood(),
                speechText: _stepSpeech(),
                size: 86,
              ),
            ),

            // Step Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: _buildStepBody(context),
              ),
            ),

            // Bottom Tactile Action Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: isDark
                    ? StriveColors.darkSurface
                    : StriveColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: StriveColors.border(context),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Strive3DButton(
                    fullWidth: true,
                    color: StriveColors.emerald,
                    onPressed: () {
                      if (_step < 3) {
                        setState(() => _step += 1);
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _step < 3
                          ? 'LANJUTKAN TAHAP ${_step + 2}'
                          : '🔥 MULAI PERJUANGAN 2027 SEKARANG!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (_step == 0) ...[
                    const SizedBox(height: 10),
                    Strive3DButton(
                      fullWidth: true,
                      color: StriveColors.indigo,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      onPressed: () async {
                        await context
                            .read<StorageService>()
                            .loadFourMonthRealisticDemoData();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'INSTANT DEMO: Muat Data Realistis 4 Bulan',
                            style: TextStyle(fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody(BuildContext context) {
    switch (_step) {
      case 0:
        return _buildStep1Identity(context);
      case 1:
        return _buildStep2Tracks(context);
      case 2:
        return _buildStep3Targets(context);
      case 3:
      default:
        return _buildStep4TimeCapsule(context);
    }
  }

  Widget _buildStep1Identity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TAHAP 1: IDENTITAS KOMANDAN',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Nama Panggilan / Callsign',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nicknameCtrl,
          decoration: const InputDecoration(
            hintText: 'Contoh: Komandan Arya / Srikandi Nadia',
            prefixIcon: Icon(Icons.person_rounded),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Kelas & Asal Sekolah / Gap Year',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _schoolCtrl,
          decoration: const InputDecoration(
            hintText: 'Contoh: Kelas 12 SMAN 3 / Alumni 2026',
            prefixIcon: Icon(Icons.school_rounded),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Kategori Gender (Wajib untuk Tabel Samapta Fisik)',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Strive3DChoiceTile(
          title: 'Taruna Pria (Pull-up & Lari 3200m Max)',
          subtitle:
              'Samapta B1: Pull-up 17x = Skor 100 | Lari 12m >= 2400m Aman',
          icon: Icons.male_rounded,
          selected: _gender == 'Pria',
          activeColor: StriveColors.sky,
          onTap: () => setState(() => _gender = 'Pria'),
        ),
        const SizedBox(height: 10),
        Strive3DChoiceTile(
          title: 'Taruni Wanita (Chinning & Lari 2650m Max)',
          subtitle:
              'Samapta B1: Chinning 63x = Skor 100 | Lari 12m >= 2100m Aman',
          icon: Icons.female_rounded,
          selected: _gender == 'Wanita',
          activeColor: StriveColors.amber,
          onTap: () => setState(() => _gender = 'Wanita'),
        ),
      ],
    );
  }

  Widget _buildStep2Tracks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TAHAP 2: PILIH JALUR TEMPUR (MULTI-TRACK)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Centang satu atau semua jalur yang kamu perjuangkan di 2027:',
          style: TextStyle(color: StriveColors.textSecondary(context)),
        ),
        const SizedBox(height: 14),
        Strive3DChoiceTile(
          title: 'Track 1: UTBK-SNBT 2027 (7 Subtes Wajib)',
          subtitle: 'PU • PPU • PBM • PK • LBI • LBE • PM (Skala 0–1000)',
          icon: Icons.psychology_rounded,
          selected: _selectedTracks.contains('UTBK'),
          activeColor: StriveColors.emerald,
          onTap: () {
            setState(() {
              if (_selectedTracks.contains('UTBK') &&
                  _selectedTracks.length > 1) {
                _selectedTracks.remove('UTBK');
              } else {
                _selectedTracks.add('UTBK');
              }
            });
          },
        ),
        const SizedBox(height: 10),
        Strive3DChoiceTile(
          title: 'Track 2: TKA Saintek / Soshum + Custom',
          subtitle:
              'Matematika Lanjut, Fisika, Kimia, Biologi / Ekonomi, Geografi, Sosiologi, Sejarah',
          icon: Icons.science_rounded,
          selected: _selectedTracks.contains('TKA'),
          activeColor: StriveColors.indigo,
          onTap: () {
            setState(() {
              if (_selectedTracks.contains('TKA') &&
                  _selectedTracks.length > 1) {
                _selectedTracks.remove('TKA');
              } else {
                _selectedTracks.add('TKA');
              }
            });
          },
        ),
        if (_selectedTracks.contains('TKA')) ...[
          const SizedBox(height: 10),
          Strive3DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fokus Rumpun TKA & Subtes Tambahan:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Strive3DButton(
                        color: _tkaCategory == 'Saintek'
                            ? StriveColors.indigo
                            : Colors.blueGrey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onPressed: () =>
                            setState(() => _tkaCategory = 'Saintek'),
                        child: const Text('TKA SAINTEK'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Strive3DButton(
                        color: _tkaCategory == 'Soshum'
                            ? StriveColors.amber
                            : Colors.blueGrey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onPressed: () =>
                            setState(() => _tkaCategory = 'Soshum'),
                        child: const Text('TKA SOSHUM'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _customTkaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Custom Subtest TKA (Opsional)',
                    hintText: 'Misal: Informatika / Bahasa Arab / Akuntansi',
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Strive3DChoiceTile(
          title: 'Track 3: Sekolah Kedinasan (SKD + Psikotes + Samapta)',
          subtitle:
              'SKD CAT (TWK/TIU/TKP) • Psikotes (Kecermatan Pauli) • Tes Fisik Samapta A & B',
          icon: Icons.military_tech_rounded,
          selected: _selectedTracks.contains('KEDINASAN'),
          activeColor: StriveColors.amber,
          onTap: () {
            setState(() {
              if (_selectedTracks.contains('KEDINASAN') &&
                  _selectedTracks.length > 1) {
                _selectedTracks.remove('KEDINASAN');
              } else {
                _selectedTracks.add('KEDINASAN');
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildStep3Targets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TAHAP 3: TARGET KAMPUS & PASSING GRADE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),

        // PTN Target Card
        Strive3DCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_balance_rounded,
                          color: StriveColors.emerald),
                      SizedBox(width: 8),
                      Text(
                        'Target PTN (UTBK-SNBT)',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _useCustomPtn = !_useCustomPtn),
                    child: Text(
                      _useCustomPtn ? 'Pilih dari Daftar' : 'Input Kustom',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!_useCustomPtn) ...[
                DropdownButtonFormField<InstitutionData>(
                  isExpanded: true,
                  initialValue: _selectedPtn,
                  decoration: const InputDecoration(labelText: 'Pilih PTN'),
                  items: PassingGradesRepository.ptnList
                      .map(
                        (ptn) => DropdownMenuItem(
                          value: ptn,
                          child: Text(
                            ptn.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      _selectedPtn = val;
                      _selectedPtnMajor = val.majors.first;
                      _targetUtbkScoreCtrl.text =
                          _selectedPtnMajor.targetScore.toString();
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<MajorPassingGrade>(
                  isExpanded: true,
                  initialValue: _selectedPtnMajor,
                  decoration:
                      const InputDecoration(labelText: 'Pilih Program Studi'),
                  items: _selectedPtn.majors
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            '${m.name} (${m.targetScore} • ${m.tier})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      _selectedPtnMajor = val;
                      _targetUtbkScoreCtrl.text = val.targetScore.toString();
                    });
                  },
                ),
              ] else ...[
                TextField(
                  controller: _customPtnNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Universitas Kustom',
                    hintText: 'Misal: Universitas Negeri Sebelas Maret (UNS)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _customPtnMajorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Program Studi Kustom',
                    hintText: 'Misal: S1 Kedokteran / Teknik Informatika',
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _targetUtbkScoreCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Skor Aman UTBK (0 - 1000)',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Sekolah Kedinasan Target Card
        Strive3DCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_rounded, color: StriveColors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Target Sekolah Kedinasan (SKD & Samapta)',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<InstitutionData>(
                isExpanded: true,
                initialValue: _selectedKedinasan,
                decoration: const InputDecoration(
                    labelText: 'Pilih Sekolah Kedinasan'),
                items: PassingGradesRepository.kedinasanList
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(k.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedKedinasan = val;
                    _selectedKedinasanMajor = val.majors.first;
                    _targetSkdScoreCtrl.text =
                        _selectedKedinasanMajor.targetScore.toString();
                    _targetSamaptaCtrl.text = _selectedKedinasanMajor
                        .targetSamapta
                        .toInt()
                        .toString();
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<MajorPassingGrade>(
                isExpanded: true,
                initialValue: _selectedKedinasanMajor,
                decoration:
                    const InputDecoration(labelText: 'Pilih Jurusan / Prodi'),
                items: _selectedKedinasan.majors
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          '${m.name} (SKD ${m.targetScore}+)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedKedinasanMajor = val;
                    _targetSkdScoreCtrl.text = val.targetScore.toString();
                    _targetSamaptaCtrl.text =
                        val.targetSamapta.toInt().toString();
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _targetSkdScoreCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target SKD (Max 550)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _targetSamaptaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target Samapta (0-100)',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4TimeCapsule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TAHAP 4: KAPSUL WAKTU MEI 2027',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Tulis pesan motivasi terdalam untuk dirimu di masa depan. Surat ini akan disimpan 100% offline dan disegel hingga 1 Mei 2027.',
          style: TextStyle(color: StriveColors.textSecondary(context)),
        ),
        const SizedBox(height: 14),
        Strive3DCard(
          borderColor: StriveColors.amber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, color: StriveColors.amber),
                  SizedBox(width: 8),
                  Text(
                    'TERKUNCI SAMPAI: 1 MEI 2027',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: StriveColors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _timeCapsuleCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Tulis surat kapsul waktumu di sini...',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
