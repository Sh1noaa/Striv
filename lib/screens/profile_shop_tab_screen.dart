import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/passing_grades.dart';
import '../models/strive_models.dart';
import '../services/storage_service.dart';
import '../widgets/ignis_mascot_widget.dart';
import '../widgets/strive_3d_button.dart';
import '../widgets/strive_theme.dart';

class ProfileShopTabScreen extends StatefulWidget {
  const ProfileShopTabScreen({super.key});

  @override
  State<ProfileShopTabScreen> createState() => _ProfileShopTabScreenState();
}

class _ProfileShopTabScreenState extends State<ProfileShopTabScreen> {
  bool _peekTimeCapsule = false;

  void _showEditTargetsDialog(BuildContext context, StorageService storage) {
    final p = storage.profile;
    if (p == null) return;

    final nickCtrl = TextEditingController(text: p.nickname);
    final ptnNameCtrl = TextEditingController(text: p.targetPtnName);
    final ptnMajorCtrl = TextEditingController(text: p.targetPtnMajor);
    final utbkScoreCtrl =
        TextEditingController(text: p.targetUtbkScore.toInt().toString());
    final kedNameCtrl = TextEditingController(text: p.targetKedinasanName);
    final kedMajorCtrl = TextEditingController(text: p.targetKedinasanMajor);
    final skdScoreCtrl = TextEditingController(text: p.targetSkdScore.toString());
    final samaptaScoreCtrl =
        TextEditingController(text: p.targetSamaptaScore.toInt().toString());
    String gender = p.gender;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Edit Profil & Target 2027',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nickCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nama Panggilan'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Taruna Pria'),
                            selected: gender == 'Pria',
                            onSelected: (_) =>
                                setDialogState(() => gender = 'Pria'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Taruni Wanita'),
                            selected: gender == 'Wanita',
                            onSelected: (_) =>
                                setDialogState(() => gender = 'Wanita'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ptnNameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Target PTN'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ptnMajorCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Jurusan PTN'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: utbkScoreCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Target Skor UTBK (0-1000)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: kedNameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Target Sekolah Kedinasan'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: kedMajorCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Jurusan Kedinasan'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: skdScoreCtrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Target SKD'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: samaptaScoreCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Target Samapta'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await storage.saveProfile(
                      p.copyWith(
                        nickname: nickCtrl.text.trim(),
                        gender: gender,
                        targetPtnName: ptnNameCtrl.text.trim(),
                        targetPtnMajor: ptnMajorCtrl.text.trim(),
                        targetUtbkScore:
                            double.tryParse(utbkScoreCtrl.text.trim()) ??
                                p.targetUtbkScore,
                        targetKedinasanName: kedNameCtrl.text.trim(),
                        targetKedinasanMajor: kedMajorCtrl.text.trim(),
                        targetSkdScore:
                            int.tryParse(skdScoreCtrl.text.trim()) ??
                                p.targetSkdScore,
                        targetSamaptaScore:
                            double.tryParse(samaptaScoreCtrl.text.trim()) ??
                                p.targetSamaptaScore,
                      ),
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPasteJsonImportDialog(
    BuildContext context,
    StorageService storage,
  ) {
    final jsonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Paste JSON Backup',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: jsonCtrl,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Tempelkan isi file backup JSON Strive di sini...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok =
                  await storage.importBackupFromJsonString(jsonCtrl.text);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor:
                        ok ? StriveColors.emerald : StriveColors.rose,
                    content: Text(
                      ok
                          ? '✅ Backup JSON Berhasil Dipulihkan!'
                          : '❌ Format JSON tidak valid!',
                    ),
                  ),
                );
              }
            },
            child: const Text('Pulihkan Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final profile = storage.profile;

    final unlockDate = DateTime.tryParse(
          profile?.timeCapsuleUnlockDate ?? '2027-05-01',
        ) ??
        DateTime(2027, 5, 1);
    final daysUntilMay2027 =
        unlockDate.difference(DateTime.now()).inDays.clamp(0, 9999);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Profile Hero Card + Theme Toggle
          Strive3DCard(
            borderColor: StriveColors.emerald,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IgnisMascotWidget(
                      mood: storage.currentIgnisMood,
                      equippedAccessory: storage.equippedAccessory,
                      showSpeechBubble: false,
                      size: 82,
                      onTap: () => storage.cyclePreviewMood(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.nickname ?? 'Komandan Strive',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${profile?.schoolGrade ?? "Kelas 12"} • Gender: ${profile?.gender ?? "Pria"}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: StriveColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _miniBadge(
                                'LVL ${storage.level}',
                                StriveColors.indigo,
                              ),
                              _miniBadge(
                                '🔥 ${storage.streakCount} Hari',
                                StriveColors.amber,
                              ),
                              _miniBadge(
                                '❄️ ${storage.streakFreezes} Freeze',
                                StriveColors.sky,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ubah Tema Gelap/Terang',
                      onPressed: () => storage.toggleThemeMode(),
                      icon: Icon(
                        storage.isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: StriveColors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Strive3DButton(
                        color: StriveColors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onPressed: () =>
                            _showEditTargetsDialog(context, storage),
                        child: const Text(
                          '✏️ Edit Target Kampus & Gender',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Strive3DButton(
                      color: StriveColors.amber,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      onPressed: () {
                        storage.triggerStreakNotification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '🔔 Notifikasi Pengingat Streak Ignis Dikirim!',
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.notifications_active_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Interactive Mascot Mood Lab (Test All 5 Mascot Expressions)
          Strive3DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎭 LABORATORIUM EKSPRESI IGNIS (5 MODE MASKOT)',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ketuk untuk menguji kelima ekspresi & dialog otomatis Ignis:',
                  style: TextStyle(
                    fontSize: 12,
                    color: StriveColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _moodTestChip(
                      storage,
                      IgnisMood.happyHype,
                      '1. Happy / Hype',
                      StriveColors.amber,
                    ),
                    _moodTestChip(
                      storage,
                      IgnisMood.angryGuilt,
                      '2. Angry Duolingo',
                      StriveColors.rose,
                    ),
                    _moodTestChip(
                      storage,
                      IgnisMood.cryingFrozen,
                      '3. Crying / Frozen',
                      StriveColors.sky,
                    ),
                    _moodTestChip(
                      storage,
                      IgnisMood.coachSpartan,
                      '4. Spartan Coach',
                      StriveColors.emerald,
                    ),
                    _moodTestChip(
                      storage,
                      IgnisMood.burnoutDoctor,
                      '5. Burnout Doctor',
                      const Color(0xFF14B8A6),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. MASCOT & STREAK SHOP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.storefront_rounded, color: StriveColors.amber),
                  SizedBox(width: 6),
                  Text(
                    'MASCOT & STREAK SHOP',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StriveColors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🪙 ${storage.coins} Koin',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: StriveColors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Buy Streak Freeze Card
          Strive3DCard(
            borderColor: StriveColors.sky,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StriveColors.sky.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.ac_unit_rounded,
                    color: StriveColors.sky,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streak Freeze (Stok: ${storage.streakFreezes})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Melindungi api streak-mu jika lupa latihan 1 hari.',
                        style: TextStyle(
                          fontSize: 12,
                          color: StriveColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Strive3DButton(
                  color: StriveColors.sky,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  onPressed: () {
                    final ok = storage.buyStreakFreeze();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            ok ? StriveColors.sky : StriveColors.rose,
                        content: Text(
                          ok
                              ? '❄️ +1 Streak Freeze berhasil dibeli!'
                              : 'Koin belum cukup (butuh 100 Koin)!',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    '100 🪙',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Cosmetic Accessories List
          ...PassingGradesRepository.shopAccessories.map((acc) {
            final unlocked = storage.unlockedAccessories.contains(acc.id);
            final equipped = storage.equippedAccessory == acc.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Strive3DCard(
                borderColor: equipped ? StriveColors.emerald : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  acc.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _miniBadge(acc.badgeText, StriveColors.amber),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            acc.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: StriveColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Strive3DButton(
                      color: equipped
                          ? StriveColors.emerald
                          : (unlocked
                              ? StriveColors.indigo
                              : StriveColors.amber),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      onPressed: () {
                        final ok = storage.buyOrEquipAccessory(acc);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: StriveColors.rose,
                              content: Text(
                                'Koin belum cukup untuk membeli ${acc.name} (${acc.costCoins} Koin)!',
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        equipped
                            ? 'DIPAKAI'
                            : (unlocked ? 'PAKAI' : '${acc.costCoins} 🪙'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // 4. RPG ACHIEVEMENT BADGES
          const Row(
            children: [
              Icon(Icons.military_tech_rounded, color: StriveColors.emerald),
              SizedBox(width: 6),
              Text(
                'RPG ACHIEVEMENT BADGES',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAchievementBadgesGrid(context, storage),
          const SizedBox(height: 18),

          // 5. TIME CAPSULE LETTER (LOCKED UNTIL MAY 2027)
          Strive3DCard(
            borderColor: StriveColors.amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_clock_rounded,
                        color: StriveColors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'KAPSUL WAKTU MEI 2027 ($daysUntilMay2027 HARI LAGI)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: StriveColors.amber,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(
                          () => _peekTimeCapsule = !_peekTimeCapsule),
                      child: Text(
                        _peekTimeCapsule ? 'Kunci Kembali' : 'Intip Surat',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _peekTimeCapsule
                      ? (profile?.timeCapsuleLetter.isNotEmpty == true
                          ? profile!.timeCapsuleLetter
                          : 'Belum ada surat kapsul waktu.')
                      : '🔒 Surat pribadimu disegel rapat di memori lokal sampai 1 Mei 2027 (Musim UTBK-SNBT & Seleksi Kedinasan). Teruslah berlatih agar saat surat ini terbuka, kamu tersenyum bangga!',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontStyle:
                        _peekTimeCapsule ? FontStyle.normal : FontStyle.italic,
                    color: StriveColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 6. APK JSON BACKUP EXPORT / IMPORT & DEMO DATA
          Strive3DCard(
            borderColor: StriveColors.indigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.backup_rounded, color: StriveColors.indigo),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '100% OFFLINE STORAGE & JSON BACKUP (.APK)',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Amankan seluruh data TryOut, SKD, Samapta & Streak sebelum update APK:',
                  style: TextStyle(
                    fontSize: 12,
                    color: StriveColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Strive3DButton(
                  fullWidth: true,
                  color: StriveColors.emerald,
                  onPressed: () async {
                    await storage.shareBackupFile();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ios_share_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('EXPORT & BAGIKAN FILE JSON BACKUP'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Strive3DButton(
                        color: StriveColors.sky,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () async {
                          final ok = await storage.pickAndImportBackupFile();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: ok
                                    ? StriveColors.emerald
                                    : StriveColors.amber,
                                content: Text(
                                  ok
                                      ? '✅ File Backup JSON Berhasil Diimpor!'
                                      : 'Impor file dibatalkan.',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          '📂 Pilih File JSON',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Strive3DButton(
                        color: StriveColors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: storage.exportBackupJson()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '📋 JSON Backup disalin! Bisa ditempel di mana saja.',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          '📋 Salin Teks JSON',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Strive3DButton(
                        color: StriveColors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        onPressed: () =>
                            _showPasteJsonImportDialog(context, storage),
                        child: const Text(
                          '📥 Paste JSON Backup',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Strive3DButton(
                        color: StriveColors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        onPressed: () async {
                          await storage.loadFourMonthRealisticDemoData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: StriveColors.emerald,
                                content: Text(
                                  '⚡ Data Realistis 4 Bulan Berhasil Dimuat!',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          '⚡ Muat Demo 4 Bulan',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _moodTestChip(
    StorageService storage,
    IgnisMood mood,
    String label,
    Color color,
  ) {
    final active = storage.currentIgnisMood == mood;
    return GestureDetector(
      onTap: () => storage.setOverrideMood(mood),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: active ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementBadgesGrid(
    BuildContext context,
    StorageService storage,
  ) {
    final badges = [
      (
        'Api Pertama',
        'Selesaikan sesi latihan pertama',
        Icons.local_fire_department_rounded,
        storage.dailyLogs.isNotEmpty,
        StriveColors.amber,
      ),
      (
        'Ambis 7-Hari',
        'Capai streak >= 7 hari beruntun',
        Icons.whatshot_rounded,
        storage.streakCount >= 7,
        StriveColors.rose,
      ),
      (
        'SNBT 700+ Club',
        'Rata-rata UTBK tembus >= 700',
        Icons.school_rounded,
        storage.averageUtbkScore >= 700,
        StriveColors.emerald,
      ),
      (
        'Penakluk BKN',
        'Lulus semua ambang batas SKD CAT',
        Icons.verified_user_rounded,
        storage.skdTryouts.any((s) => s.passedAll),
        StriveColors.indigo,
      ),
      (
        'Spartan Pull-up',
        'Tembus >= 10 Pull-up / >= 35 Chinning',
        Icons.fitness_center_rounded,
        storage.samaptaLogs.any((s) => s.pullUpOrChinningReps >= 10),
        StriveColors.sky,
      ),
      (
        'Sepuh Silabus',
        'Minimal 5 topik berstatus Hijau',
        Icons.workspace_premium_rounded,
        storage.syllabus.where((s) => s.status == 2).length >= 5,
        StriveColors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, i) {
        final b = badges[i];
        final unlocked = b.$4;
        final col = unlocked ? b.$5 : Colors.grey;

        return Strive3DCard(
          padding: const EdgeInsets.all(10),
          borderColor: col.withValues(alpha: 0.6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(b.$3, color: col, size: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.$1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        color: unlocked
                            ? StriveColors.textPrimary(context)
                            : StriveColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: StriveColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
