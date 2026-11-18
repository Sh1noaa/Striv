import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/passing_grades.dart';
import '../models/strive_models.dart';

class StorageService extends ChangeNotifier {
  static const String _keyProfile = 'strive_profile';
  static const String _keyDailyLogs = 'strive_daily_logs';
  static const String _keyUtbkTryouts = 'strive_utbk_tryouts';
  static const String _keySkdTryouts = 'strive_skd_tryouts';
  static const String _keyPsikotesLogs = 'strive_psikotes_logs';
  static const String _keySamaptaLogs = 'strive_samapta_logs';
  static const String _keySyllabus = 'strive_syllabus';
  static const String _keyVault = 'strive_vault';
  static const String _keyEconomy = 'strive_economy';

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  List<DailyStudyLog> _dailyLogs = [];
  List<DailyStudyLog> get dailyLogs => List.unmodifiable(_dailyLogs);

  List<UtbkTkaTryout> _utbkTryouts = [];
  List<UtbkTkaTryout> get utbkTryouts => List.unmodifiable(_utbkTryouts);

  List<SkdTryout> _skdTryouts = [];
  List<SkdTryout> get skdTryouts => List.unmodifiable(_skdTryouts);

  List<PsikotesLog> _psikotesLogs = [];
  List<PsikotesLog> get psikotesLogs => List.unmodifiable(_psikotesLogs);

  List<SamaptaLog> _samaptaLogs = [];
  List<SamaptaLog> get samaptaLogs => List.unmodifiable(_samaptaLogs);

  List<SyllabusItem> _syllabus = [];
  List<SyllabusItem> get syllabus => List.unmodifiable(_syllabus);

  List<VaultItem> _vault = [];
  List<VaultItem> get vault => List.unmodifiable(_vault);

  // Economy & HUD State
  int _streakCount = 0;
  int get streakCount => _streakCount;

  String _lastActiveDate = '';
  String get lastActiveDate => _lastActiveDate;

  int _streakFreezes = 1;
  int get streakFreezes => _streakFreezes;

  bool _streakFrozenToday = false;
  bool get streakFrozenToday => _streakFrozenToday;

  int _coins = 200;
  int get coins => _coins;

  int _exp = 120;
  int get exp => _exp;

  int get level => (_exp ~/ 250) + 1;
  double get levelProgress => (_exp % 250) / 250.0;

  String _equippedAccessory = 'none';
  String get equippedAccessory => _equippedAccessory;

  List<String> _unlockedAccessories = ['none'];
  List<String> get unlockedAccessories => List.unmodifiable(_unlockedAccessories);

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  String _activeTrackFilter = 'Semua'; // 'Semua', 'UTBK & TKA', 'Kedinasan'
  String get activeTrackFilter => _activeTrackFilter;

  IgnisMood? _overrideMood;
  IgnisMood? get overrideMood => _overrideMood;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initNotifications();
    _loadFromPrefs();
    _checkStreakContinuity();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initNotifications() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _notificationsPlugin.initialize(settings: initSettings);
    } catch (e) {
      debugPrint('Notification init warning: $e');
    }
  }

  Future<void> triggerStreakNotification({
    String title = '🔥 Ignis Memanggil Komandan!',
    String body =
        'Yakin mau rebahan? Pesaing PTN & Taruna lagi push-up dan bahas PK tuh!',
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'strive_streak_channel',
        'Strive Streak & Alarm',
        channelDescription: 'Pengingat latihan harian UTBK, TKA & Kedinasan 2027',
        importance: Importance.max,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      await _notificationsPlugin.show(
        id: 2027,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Notification trigger skipped: $e');
    }
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;

    final profileRaw = _prefs!.getString(_keyProfile);
    if (profileRaw != null && profileRaw.isNotEmpty) {
      try {
        _profile = UserProfile.fromJson(
          jsonDecode(profileRaw) as Map<String, dynamic>,
        );
      } catch (_) {
        _profile = null;
      }
    } else {
      _profile = null;
    }

    _dailyLogs = _decodeList(_keyDailyLogs, DailyStudyLog.fromJson);
    _utbkTryouts = _decodeList(_keyUtbkTryouts, UtbkTkaTryout.fromJson);
    _skdTryouts = _decodeList(_keySkdTryouts, SkdTryout.fromJson);
    _psikotesLogs = _decodeList(_keyPsikotesLogs, PsikotesLog.fromJson);
    _samaptaLogs = _decodeList(_keySamaptaLogs, SamaptaLog.fromJson);

    final loadedSyllabus = _decodeList(_keySyllabus, SyllabusItem.fromJson);
    if (loadedSyllabus.isEmpty) {
      _syllabus = PassingGradesRepository.defaultSyllabus();
    } else {
      _syllabus = loadedSyllabus;
    }

    final loadedVault = _decodeList(_keyVault, VaultItem.fromJson);
    if (loadedVault.isEmpty) {
      _vault = _defaultVaultItems();
    } else {
      _vault = loadedVault;
    }

    final ecoRaw = _prefs!.getString(_keyEconomy);
    if (ecoRaw != null && ecoRaw.isNotEmpty) {
      try {
        final eco = jsonDecode(ecoRaw) as Map<String, dynamic>;
        _streakCount = (eco['streakCount'] as num?)?.toInt() ?? 0;
        _lastActiveDate = eco['lastActiveDate']?.toString() ?? '';
        _streakFreezes = (eco['streakFreezes'] as num?)?.toInt() ?? 1;
        _streakFrozenToday = eco['streakFrozenToday'] == true;
        _coins = (eco['coins'] as num?)?.toInt() ?? 200;
        _exp = (eco['exp'] as num?)?.toInt() ?? 120;
        _equippedAccessory = eco['equippedAccessory']?.toString() ?? 'none';
        _unlockedAccessories = (eco['unlockedAccessories'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ['none'];
        _isDarkMode = eco['isDarkMode'] != false;
        _activeTrackFilter = eco['activeTrackFilter']?.toString() ?? 'Semua';
      } catch (_) {}
    }
  }

  List<T> _decodeList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll() async {
    if (_prefs == null) return;
    if (_profile != null) {
      await _prefs!.setString(_keyProfile, jsonEncode(_profile!.toJson()));
    } else {
      await _prefs!.remove(_keyProfile);
    }
    await _prefs!.setString(
      _keyDailyLogs,
      encodeJsonList(_dailyLogs, (e) => e.toJson()),
    );
    await _prefs!.setString(
      _keyUtbkTryouts,
      encodeJsonList(_utbkTryouts, (e) => e.toJson()),
    );
    await _prefs!.setString(
      _keySkdTryouts,
      encodeJsonList(_skdTryouts, (e) => e.toJson()),
    );
    await _prefs!.setString(
      _keyPsikotesLogs,
      encodeJsonList(_psikotesLogs, (e) => e.toJson()),
    );
    await _prefs!.setString(
      _keySamaptaLogs,
      encodeJsonList(_samaptaLogs, (e) => e.toJson()),
    );
    await _prefs!.setString(
      _keySyllabus,
      encodeJsonList(_syllabus, (e) => e.toJson()),
    );
    await _prefs!.setString(
      _keyVault,
      encodeJsonList(_vault, (e) => e.toJson()),
    );
    await _prefs!.setString(
      _keyEconomy,
      jsonEncode({
        'streakCount': _streakCount,
        'lastActiveDate': _lastActiveDate,
        'streakFreezes': _streakFreezes,
        'streakFrozenToday': _streakFrozenToday,
        'coins': _coins,
        'exp': _exp,
        'equippedAccessory': _equippedAccessory,
        'unlockedAccessories': _unlockedAccessories,
        'isDarkMode': _isDarkMode,
        'activeTrackFilter': _activeTrackFilter,
      }),
    );
  }

  String get todayDateString => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _checkStreakContinuity() {
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    if (_lastActiveDate.isEmpty || _lastActiveDate == todayStr) return;

    try {
      final lastDate = DateTime.parse(_lastActiveDate);
      final diffDays = DateTime(today.year, today.month, today.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      if (diffDays == 1) {
        // Streak is still valid, awaiting today's checkin
        _streakFrozenToday = false;
      } else if (diffDays > 1) {
        // Missed 1 or more days
        if (_streakFreezes > 0 && diffDays == 2) {
          _streakFreezes -= 1;
          _streakFrozenToday = true;
          _lastActiveDate = DateFormat('yyyy-MM-dd')
              .format(today.subtract(const Duration(days: 1)));
        } else {
          _streakCount = 0;
          _streakFrozenToday = true;
        }
        _saveAll();
      }
    } catch (_) {}
  }

  int get todayStudyMinutes {
    final t = todayDateString;
    return _dailyLogs
        .where((e) => e.date == t)
        .fold<int>(0, (sum, e) => sum + e.minutes);
  }

  /// Dynamic Ignis Mascot Mood Engine (5 states)
  IgnisMood get currentIgnisMood {
    if (_overrideMood != null) return _overrideMood!;

    // 5. Burnout Doctor Mode: if last 3 daily logs are all "Otak/Badan Ngebul"
    if (_dailyLogs.length >= 3) {
      final lastThree = _dailyLogs.take(3).toList();
      if (lastThree.every((e) => e.fatigueLevel == 'Otak/Badan Ngebul')) {
        return IgnisMood.burnoutDoctor;
      }
    }

    // 3. Crying / Frozen Mode: when Streak Freeze consumed or streak dropped to 0
    if (_streakFrozenToday || (_streakCount == 0 && _dailyLogs.isNotEmpty)) {
      return IgnisMood.cryingFrozen;
    }

    // 2. Angry / Guilt-Trip Duolingo Mode: after 18:00 WIB if today's minutes == 0,
    // OR if the latest SKD subtest fails ambang batas
    final hour = DateTime.now().hour;
    final latestSkdFailed =
        _skdTryouts.isNotEmpty && !_skdTryouts.first.passedAll;
    if ((hour >= 18 && todayStudyMinutes == 0) || latestSkdFailed) {
      return IgnisMood.angryGuilt;
    }

    // 1. Happy / Hype Mode: default when active, high pull-ups, or new records
    return IgnisMood.happyHype;
  }

  String get currentIgnisSpeech {
    final name = _profile?.nickname ?? 'Komandan';
    switch (currentIgnisMood) {
      case IgnisMood.happyHype:
        final bestPull = _samaptaLogs.isNotEmpty
            ? _samaptaLogs.first.pullUpOrChinningReps
            : 0;
        if (bestPull >= 10) {
          return 'Mantap $name! Nilai TIU & Pull-up ($bestPull rep) makin ngeri! Pertahankan api tempurmu menuju 2027!';
        }
        return 'Mantap $name! Nilai TIU & Pull-up makin ngeri! Hari ini sudah sikat $todayStudyMinutes menit latihan!';
      case IgnisMood.angryGuilt:
        if (_skdTryouts.isNotEmpty && !_skdTryouts.first.passedAll) {
          return 'Awas Nilai Mati SKD, $name! Yakin mau rebahan? Pesaing PTN & Taruna lagi push-up dan bahas PK tuh!';
        }
        return 'Yakin mau rebahan? Pesaing PTN & Taruna lagi push-up dan bahas PK tuh! Sikat minimal 25 menit sekarang!';
      case IgnisMood.cryingFrozen:
        return 'Brrr... Streak Freeze terpakai atau api streak-mu membeku! Ayo nyalakan kembali obor latihan hari ini, $name!';
      case IgnisMood.coachSpartan:
        return 'SIAP GERAK, $name! Punggung tegak, kunci core, tarik dagu lewati palang! Progressive overload tidak kenal alasan!';
      case IgnisMood.burnoutDoctor:
        return 'Dokter Ignis mendeteksi "Otak/Badan Ngebul" 3x berturut-turut! Tidur 7-8 jam, hidrasi, dan lakukan deload peregangan dulu ya!';
    }
  }

  void cyclePreviewMood() {
    const moods = IgnisMood.values;
    if (_overrideMood == null) {
      _overrideMood = moods.first;
    } else {
      final idx = moods.indexOf(_overrideMood!);
      if (idx + 1 < moods.length) {
        _overrideMood = moods[idx + 1];
      } else {
        _overrideMood = null; // return to automatic
      }
    }
    notifyListeners();
  }

  void setOverrideMood(IgnisMood? mood) {
    _overrideMood = mood;
    notifyListeners();
  }

  void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    _saveAll();
    notifyListeners();
  }

  void setTrackFilter(String filter) {
    _activeTrackFilter = filter;
    _saveAll();
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    final isFirstTime = _profile == null;
    _profile = newProfile;
    if (isFirstTime && _streakCount == 0) {
      _streakCount = 1;
      _lastActiveDate = todayDateString;
    }
    await _saveAll();
    notifyListeners();
  }

  Future<void> logStudyOrWorkoutSession({
    required String track,
    required String subtestCode,
    required int minutes,
    required String fatigueLevel,
    String notes = '',
  }) async {
    final today = todayDateString;
    final log = DailyStudyLog(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      date: today,
      track: track,
      subtestCode: subtestCode,
      minutes: minutes,
      fatigueLevel: fatigueLevel,
      notes: notes,
    );
    _dailyLogs.insert(0, log);

    // Streak & Economy Rewards
    if (_lastActiveDate != today) {
      _streakCount += 1;
      _lastActiveDate = today;
      _streakFrozenToday = false;
    }
    final earnedExp = (minutes * 3).clamp(15, 300);
    final earnedCoins = (minutes * 2).clamp(10, 200);
    _exp += earnedExp;
    _coins += earnedCoins;

    // Auto-evaluate mascot mood
    if (fatigueLevel == 'Otak/Badan Ngebul' &&
        _dailyLogs.take(3).length == 3 &&
        _dailyLogs.take(3).every((e) => e.fatigueLevel == 'Otak/Badan Ngebul')) {
      _overrideMood = IgnisMood.burnoutDoctor;
    } else {
      _overrideMood = IgnisMood.happyHype;
    }

    await _saveAll();
    notifyListeners();
  }

  Future<void> addUtbkTkaTryout(UtbkTkaTryout tryout) async {
    _utbkTryouts.insert(0, tryout);
    _utbkTryouts.sort((a, b) => b.date.compareTo(a.date));
    _exp += 120;
    _coins += 80;
    _overrideMood = IgnisMood.happyHype;
    await _saveAll();
    notifyListeners();
  }

  Future<void> deleteUtbkTkaTryout(String id) async {
    _utbkTryouts.removeWhere((e) => e.id == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> addSkdTryout(SkdTryout tryout) async {
    _skdTryouts.insert(0, tryout);
    _skdTryouts.sort((a, b) => b.date.compareTo(a.date));
    _exp += 120;
    _coins += 80;
    _overrideMood =
        tryout.passedAll ? IgnisMood.happyHype : IgnisMood.angryGuilt;
    await _saveAll();
    notifyListeners();
  }

  Future<void> deleteSkdTryout(String id) async {
    _skdTryouts.removeWhere((e) => e.id == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> addPsikotesLog(PsikotesLog log) async {
    _psikotesLogs.insert(0, log);
    _psikotesLogs.sort((a, b) => b.date.compareTo(a.date));
    _exp += 90;
    _coins += 60;
    await _saveAll();
    notifyListeners();
  }

  Future<void> addSamaptaLog(SamaptaLog log) async {
    _samaptaLogs.insert(0, log);
    _samaptaLogs.sort((a, b) => b.date.compareTo(a.date));
    _exp += 130;
    _coins += 90;
    if (log.pullUpOrChinningReps >= 10) {
      _overrideMood = IgnisMood.happyHype;
    } else {
      _overrideMood = IgnisMood.coachSpartan;
    }
    await _saveAll();
    notifyListeners();
  }

  Future<void> cycleSyllabusStatus(String id) async {
    final idx = _syllabus.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final current = _syllabus[idx];
    final nextStatus = (current.status + 1) % 3;
    _syllabus[idx] = current.copyWith(status: nextStatus);
    if (nextStatus == 2) {
      _exp += 25;
      _coins += 15;
    }
    await _saveAll();
    notifyListeners();
  }

  Future<void> addSyllabusItem({
    required String track,
    required String subtest,
    required String topic,
  }) async {
    _syllabus.add(
      SyllabusItem(
        id: 'syl-${DateTime.now().millisecondsSinceEpoch}',
        track: track,
        subtest: subtest,
        topic: topic,
        status: 0,
      ),
    );
    await _saveAll();
    notifyListeners();
  }

  Future<void> addVaultItem({
    required String title,
    required String category,
    required String contentOrUrl,
    required String tag,
  }) async {
    _vault.insert(
      0,
      VaultItem(
        id: 'vlt-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: category,
        contentOrUrl: contentOrUrl,
        tag: tag,
        createdAt: todayDateString,
      ),
    );
    _exp += 20;
    await _saveAll();
    notifyListeners();
  }

  Future<void> togglePinVaultItem(String id) async {
    final idx = _vault.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _vault[idx] = _vault[idx].copyWith(isPinned: !_vault[idx].isPinned);
    await _saveAll();
    notifyListeners();
  }

  Future<void> deleteVaultItem(String id) async {
    _vault.removeWhere((e) => e.id == id);
    await _saveAll();
    notifyListeners();
  }

  // Shop Purchases
  bool buyStreakFreeze() {
    const cost = 100;
    if (_coins < cost) return false;
    _coins -= cost;
    _streakFreezes += 1;
    _saveAll();
    notifyListeners();
    return true;
  }

  bool buyOrEquipAccessory(MascotAccessory item) {
    if (_unlockedAccessories.contains(item.id)) {
      _equippedAccessory = item.id;
      _saveAll();
      notifyListeners();
      return true;
    }
    if (_coins < item.costCoins) return false;
    _coins -= item.costCoins;
    _unlockedAccessories.add(item.id);
    _equippedAccessory = item.id;
    _saveAll();
    notifyListeners();
    return true;
  }

  // Analytics Helpers
  double get averageUtbkScore {
    final utbks = _utbkTryouts.where((e) => e.category == 'UTBK').toList();
    if (utbks.isEmpty) return 0.0;
    return utbks.fold<double>(0.0, (s, e) => s + e.averageScore) / utbks.length;
  }

  double get latestUtbkScore {
    final utbks = _utbkTryouts.where((e) => e.category == 'UTBK').toList();
    if (utbks.isEmpty) return 0.0;
    return utbks.first.averageScore;
  }

  double get averageTkaScore {
    final tkas = _utbkTryouts.where((e) => e.category == 'TKA').toList();
    if (tkas.isEmpty) return 0.0;
    return tkas.fold<double>(0.0, (s, e) => s + e.averageScore) / tkas.length;
  }

  int get latestSkdTotal =>
      _skdTryouts.isNotEmpty ? _skdTryouts.first.totalScore : 0;

  double get latestSamaptaScore =>
      _samaptaLogs.isNotEmpty ? _samaptaLogs.first.finalScore : 0.0;

  Map<String, double> get subtestAverages {
    final sums = <String, double>{};
    final counts = <String, int>{};

    for (final t in _utbkTryouts) {
      t.subtestScores.forEach((code, score) {
        sums[code] = (sums[code] ?? 0.0) + score;
        counts[code] = (counts[code] ?? 0) + 1;
      });
    }

    final result = <String, double>{};
    sums.forEach((code, sum) {
      result[code] = sum / (counts[code] ?? 1);
    });
    return result;
  }

  /// Populate 4 Months of Realistic Demo Data (UTBK, TKA, SKD, Psikotes, Samapta, Daily Logs)
  Future<void> loadFourMonthRealisticDemoData() async {
    final gender = _profile?.gender ?? 'Pria';
    final isWanita = gender.toLowerCase() == 'wanita';

    _profile ??= UserProfile(
      nickname: 'Komandan Arya',
      schoolGrade: 'Kelas 12 SMAN 1 Unggulan',
      gender: gender,
      selectedTracks: const ['UTBK', 'TKA', 'KEDINASAN'],
      tkaCategory: 'Saintek',
      customTkaSubtest: 'Informatika Algoritma',
      targetPtnId: 'itb',
      targetPtnName: 'Institut Teknologi Bandung (ITB)',
      targetPtnMajor: 'STEI - Komputasi (Informatika & Sistem Informasi)',
      targetUtbkScore: 745.0,
      targetKedinasanId: 'stan',
      targetKedinasanName: 'Politeknik Keuangan Negara STAN (PKN STAN)',
      targetKedinasanMajor: 'D4 Akuntansi Sektor Publik',
      targetSkdScore: 452,
      targetSamaptaScore: 76.0,
      timeCapsuleLetter:
          'Untuk diriku di Mei 2027: Ingat setiap malam kamu latihan PK, PM, TIU, dan setiap pagi kamu lari 12 menit serta pull-up saat yang lain masih tidur. Hari pengumuman ini adalah bukti keringatmu tidak pernah berkhianat. Selamat mengenakan jaket almamater impian!',
      timeCapsuleUnlockDate: '2027-05-01',
      createdAt: '2026-08-01T07:00:00.000',
    );

    _utbkTryouts = [
      UtbkTkaTryout(
        id: 'to-utbk-5',
        name: 'TryOut Akbar SNBT Ep. 5 (November)',
        date: '2026-11-16',
        category: 'UTBK',
        subtestScores: {
          'PU': 735,
          'PPU': 710,
          'PBM': 722,
          'PK': 740,
          'LBI': 755,
          'LBE': 730,
          'PM': 748,
        },
      ),
      UtbkTkaTryout(
        id: 'to-tka-3',
        name: 'Simulasi TKA Saintek Nasional #3',
        date: '2026-11-12',
        category: 'TKA',
        subtestScores: {
          'MTK_L': 730,
          'FIS': 715,
          'KIM': 695,
          'BIO': 740,
        },
      ),
      UtbkTkaTryout(
        id: 'to-utbk-4',
        name: 'TryOut Nasional SNBT Ep. 4 (Oktober)',
        date: '2026-10-24',
        category: 'UTBK',
        subtestScores: {
          'PU': 705,
          'PPU': 688,
          'PBM': 695,
          'PK': 690,
          'LBI': 728,
          'LBE': 710,
          'PM': 708,
        },
      ),
      UtbkTkaTryout(
        id: 'to-tka-2',
        name: 'Simulasi TKA Saintek Nasional #2',
        date: '2026-10-14',
        category: 'TKA',
        subtestScores: {
          'MTK_L': 690,
          'FIS': 675,
          'KIM': 660,
          'BIO': 710,
        },
      ),
      UtbkTkaTryout(
        id: 'to-utbk-3',
        name: 'TryOut SNBT Ep. 3 (September)',
        date: '2026-09-20',
        category: 'UTBK',
        subtestScores: {
          'PU': 668,
          'PPU': 655,
          'PBM': 660,
          'PK': 640,
          'LBI': 695,
          'LBE': 680,
          'PM': 655,
        },
      ),
      UtbkTkaTryout(
        id: 'to-tka-1',
        name: 'Diagnostic TKA Saintek #1 (Agustus)',
        date: '2026-08-25',
        category: 'TKA',
        subtestScores: {
          'MTK_L': 645,
          'FIS': 630,
          'KIM': 620,
          'BIO': 670,
        },
      ),
      UtbkTkaTryout(
        id: 'to-utbk-1',
        name: 'Diagnostic Awal UTBK (Agustus)',
        date: '2026-08-15',
        category: 'UTBK',
        subtestScores: {
          'PU': 625,
          'PPU': 615,
          'PBM': 630,
          'PK': 595,
          'LBI': 660,
          'LBE': 640,
          'PM': 610,
        },
      ),
    ];

    _skdTryouts = [
      const SkdTryout(
        id: 'skd-4',
        name: 'Simulasi CAT BKN Kedinasan #4 (Nov)',
        date: '2026-11-17',
        twk: 105,
        tiu: 150,
        tkp: 196,
      ),
      const SkdTryout(
        id: 'skd-3',
        name: 'Simulasi CAT BKN Kedinasan #3 (Okt)',
        date: '2026-10-19',
        twk: 95,
        tiu: 140,
        tkp: 189,
      ),
      const SkdTryout(
        id: 'skd-2',
        name: 'Simulasi CAT BKN Kedinasan #2 (Sep)',
        date: '2026-09-18',
        twk: 80,
        tiu: 125,
        tkp: 181,
      ),
      const SkdTryout(
        id: 'skd-1',
        name: 'Diagnostic Awal SKD CAT #1 (Agu)',
        date: '2026-08-18',
        twk: 60, // Failed ambang batas early on
        tiu: 105,
        tkp: 172,
      ),
    ];

    _psikotesLogs = [
      const PsikotesLog(
        id: 'psi-3',
        name: 'Simulasi Pauli/Kraepelin & Spasial #3',
        date: '2026-11-15',
        kecerdasan: 86.0,
        kepribadian: 88.0,
        kecermatanSpeed: 84.0,
        kecermatanAccuracy: 95.0,
        kecermatanStability: 89.0,
      ),
      const PsikotesLog(
        id: 'psi-2',
        name: 'Simulasi Pauli/Kraepelin & Spasial #2',
        date: '2026-10-12',
        kecerdasan: 79.0,
        kepribadian: 83.0,
        kecermatanSpeed: 76.0,
        kecermatanAccuracy: 91.0,
        kecermatanStability: 81.0,
      ),
      const PsikotesLog(
        id: 'psi-1',
        name: 'Baseline Psikotes Kedinasan #1',
        date: '2026-09-10',
        kecerdasan: 72.0,
        kepribadian: 78.0,
        kecermatanSpeed: 68.0,
        kecermatanAccuracy: 86.0,
        kecermatanStability: 73.0,
      ),
    ];

    _samaptaLogs = [
      SamaptaCalculator.createCalculatedLog(
        id: 'sam-4',
        date: '2026-11-17',
        gender: gender,
        lari12MenitMeters: isWanita ? 2320 : 2760,
        pullUpOrChinningReps: isWanita ? 46 : 12,
        sitUpReps: 37,
        pushUpReps: isWanita ? 31 : 38,
        shuttleRunSeconds: isWanita ? 18.1 : 16.7,
        renang25mSeconds: 24.5,
      ),
      SamaptaCalculator.createCalculatedLog(
        id: 'sam-3',
        date: '2026-10-20',
        gender: gender,
        lari12MenitMeters: isWanita ? 2150 : 2540,
        pullUpOrChinningReps: isWanita ? 38 : 9,
        sitUpReps: 34,
        pushUpReps: isWanita ? 27 : 34,
        shuttleRunSeconds: isWanita ? 18.8 : 17.3,
        renang25mSeconds: 27.0,
      ),
      SamaptaCalculator.createCalculatedLog(
        id: 'sam-2',
        date: '2026-09-22',
        gender: gender,
        lari12MenitMeters: isWanita ? 1980 : 2310,
        pullUpOrChinningReps: isWanita ? 29 : 6,
        sitUpReps: 29,
        pushUpReps: isWanita ? 22 : 29,
        shuttleRunSeconds: isWanita ? 19.6 : 18.1,
        renang25mSeconds: 30.0,
      ),
      SamaptaCalculator.createCalculatedLog(
        id: 'sam-1',
        date: '2026-08-20',
        gender: gender,
        lari12MenitMeters: isWanita ? 1750 : 1980,
        pullUpOrChinningReps: isWanita ? 18 : 3,
        sitUpReps: 24,
        pushUpReps: isWanita ? 17 : 22,
        shuttleRunSeconds: isWanita ? 20.5 : 19.1,
        renang25mSeconds: 34.0,
      ),
    ];

    // Generate 55 realistic study & workout logs across 4 months + last 30 days
    final generatedLogs = <DailyStudyLog>[];
    final now = DateTime.now();
    final subtestRotation = [
      ('UTBK', 'PK'),
      ('UTBK', 'PM'),
      ('UTBK', 'PU'),
      ('KEDINASAN', 'TIU'),
      ('FISIK', 'Pull-up & Lari'),
      ('TKA', 'MTK_L'),
      ('UTBK', 'LBI'),
      ('KEDINASAN', 'TWK'),
      ('UTBK', 'LBE'),
      ('TKA', 'FIS'),
      ('KEDINASAN', 'TKP'),
      ('UTBK', 'PBM'),
      ('UTBK', 'PPU'),
      ('TKA', 'KIM'),
    ];

    for (int i = 0; i < 65; i++) {
      final d = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(d);
      final item = subtestRotation[i % subtestRotation.length];
      final mins = 35 + ((i * 17) % 65);
      final fatigue = (i % 7 == 0)
          ? 'Otak/Badan Ngebul'
          : (i % 3 == 0 ? 'Biasa' : 'Semangat');
      generatedLogs.add(
        DailyStudyLog(
          id: 'demo-log-$i',
          date: dateStr,
          track: item.$1,
          subtestCode: item.$2,
          minutes: mins,
          fatigueLevel: fatigue,
          notes: 'Latihan intensif ${item.$2} ($mins menit)',
        ),
      );
    }

    // Add explicit logs across Aug, Sep, Oct, Nov 2026 for Monthly Cartesian Charts
    final historicalDates = [
      ('2026-08-10', 'UTBK', 'PK', 45),
      ('2026-08-14', 'UTBK', 'PM', 50),
      ('2026-08-22', 'KEDINASAN', 'TIU', 60),
      ('2026-08-28', 'FISIK', 'Lari 12m', 40),
      ('2026-09-05', 'UTBK', 'PU', 60),
      ('2026-09-12', 'TKA', 'MTK_L', 75),
      ('2026-09-19', 'KEDINASAN', 'TWK', 55),
      ('2026-09-25', 'UTBK', 'PK', 80),
      ('2026-10-04', 'UTBK', 'PM', 90),
      ('2026-10-11', 'KEDINASAN', 'TIU', 85),
      ('2026-10-18', 'TKA', 'FIS', 70),
      ('2026-10-27', 'FISIK', 'Pull-up', 50),
      ('2026-11-02', 'UTBK', 'PK', 95),
      ('2026-11-08', 'UTBK', 'LBE', 75),
      ('2026-11-14', 'KEDINASAN', 'TKP', 80),
    ];
    for (int j = 0; j < historicalDates.length; j++) {
      final h = historicalDates[j];
      generatedLogs.add(
        DailyStudyLog(
          id: 'hist-log-$j',
          date: h.$1,
          track: h.$2,
          subtestCode: h.$3,
          minutes: h.$4,
          fatigueLevel: 'Semangat',
          notes: 'Arsip latihan bulanan ${h.$3}',
        ),
      );
    }

    _dailyLogs = generatedLogs;
    _syllabus = PassingGradesRepository.defaultSyllabus();
    _vault = _defaultVaultItems();
    _streakCount = 24;
    _lastActiveDate = todayDateString;
    _streakFreezes = 2;
    _streakFrozenToday = false;
    _coins = 640;
    _exp = 1850;
    _unlockedAccessories = ['none', 'kacamata_ambis', 'baret_taruna'];
    _equippedAccessory = 'baret_taruna';
    _overrideMood = IgnisMood.happyHype;

    await _saveAll();
    notifyListeners();
  }

  List<VaultItem> _defaultVaultItems() {
    return [
      const VaultItem(
        id: 'vlt-1',
        title: 'Rumus Cepat PK & PM: Kombinatorika & Barisan Bertingkat',
        category: 'UTBK',
        contentOrUrl:
            'Un = a + (n-1)b + (n-1)(n-2)c/2! | Gunakan prinsip inklusi-eksklusi untuk peluang kejadian majemuk.',
        tag: 'Rumus Inti',
        createdAt: '2026-11-01',
        isPinned: true,
      ),
      const VaultItem(
        id: 'vlt-2',
        title: 'Trik TIU Meja Bundar & Silogisme Kuantor',
        category: 'SKD',
        contentOrUrl:
            'Semua A adalah B + Sebagian A adalah C => Sebagian B adalah C. Untuk meja bundar 6 kursi, kunci posisi berhadapan dulu!',
        tag: 'Strategi CAT',
        createdAt: '2026-11-05',
        isPinned: true,
      ),
      const VaultItem(
        id: 'vlt-3',
        title: 'Program Lari Cooper 12 Menit Tembus 2800m+',
        category: 'FISIK',
        contentOrUrl:
            'Senin: Interval 6x400m (Pace 1:30). Rabu: Easy Run 35m. Jumat: Tempo Run 20m + Pull-up Pyramid Set 1-5-1.',
        tag: 'Drill Samapta',
        createdAt: '2026-11-10',
        isPinned: false,
      ),
      const VaultItem(
        id: 'vlt-4',
        title: 'Konsep Kalkulus & Fisika Mekanika TKA Saintek',
        category: 'TKA',
        contentOrUrl:
            'Hukum Kekekalan Energi Mekanik + Teorema Usaha-Energi Kinetik (W = ΔEk) sering keluar di soal HOTS ITB/UI.',
        tag: 'Catatan TKA',
        createdAt: '2026-11-12',
        isPinned: false,
      ),
    ];
  }

  /// Export Full Offline State as JSON String
  String exportBackupJson() {
    final payload = {
      'app': 'Strive 2027 - Road to UTBK, TKA & Sekolah Kedinasan',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _profile?.toJson(),
      'economy': {
        'streakCount': _streakCount,
        'lastActiveDate': _lastActiveDate,
        'streakFreezes': _streakFreezes,
        'streakFrozenToday': _streakFrozenToday,
        'coins': _coins,
        'exp': _exp,
        'equippedAccessory': _equippedAccessory,
        'unlockedAccessories': _unlockedAccessories,
        'isDarkMode': _isDarkMode,
        'activeTrackFilter': _activeTrackFilter,
      },
      'dailyLogs': _dailyLogs.map((e) => e.toJson()).toList(),
      'utbkTryouts': _utbkTryouts.map((e) => e.toJson()).toList(),
      'skdTryouts': _skdTryouts.map((e) => e.toJson()).toList(),
      'psikotesLogs': _psikotesLogs.map((e) => e.toJson()).toList(),
      'samaptaLogs': _samaptaLogs.map((e) => e.toJson()).toList(),
      'syllabus': _syllabus.map((e) => e.toJson()).toList(),
      'vault': _vault.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Save JSON backup to file and open Android native Share Sheet
  Future<String> shareBackupFile() async {
    final jsonString = exportBackupJson();
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/strive_2027_backup_$stamp.json');
    await file.writeAsString(jsonString);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Backup Data Strive 2027 (UTBK, TKA & Sekolah Kedinasan)',
      ),
    );
    return file.path;
  }

  /// Import JSON Backup from raw JSON string
  Future<bool> importBackupFromJsonString(String rawJson) async {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      if (data['profile'] != null) {
        _profile = UserProfile.fromJson(
          Map<String, dynamic>.from(data['profile'] as Map),
        );
      }
      if (data['economy'] != null) {
        final eco = Map<String, dynamic>.from(data['economy'] as Map);
        _streakCount = (eco['streakCount'] as num?)?.toInt() ?? _streakCount;
        _lastActiveDate =
            eco['lastActiveDate']?.toString() ?? _lastActiveDate;
        _streakFreezes =
            (eco['streakFreezes'] as num?)?.toInt() ?? _streakFreezes;
        _coins = (eco['coins'] as num?)?.toInt() ?? _coins;
        _exp = (eco['exp'] as num?)?.toInt() ?? _exp;
        _equippedAccessory =
            eco['equippedAccessory']?.toString() ?? _equippedAccessory;
        _unlockedAccessories =
            (eco['unlockedAccessories'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                _unlockedAccessories;
      }
      if (data['dailyLogs'] is List) {
        _dailyLogs = (data['dailyLogs'] as List)
            .map((e) => DailyStudyLog.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (data['utbkTryouts'] is List) {
        _utbkTryouts = (data['utbkTryouts'] as List)
            .map((e) => UtbkTkaTryout.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (data['skdTryouts'] is List) {
        _skdTryouts = (data['skdTryouts'] as List)
            .map((e) => SkdTryout.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (data['psikotesLogs'] is List) {
        _psikotesLogs = (data['psikotesLogs'] as List)
            .map((e) => PsikotesLog.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (data['samaptaLogs'] is List) {
        _samaptaLogs = (data['samaptaLogs'] as List)
            .map((e) => SamaptaLog.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (data['syllabus'] is List) {
        _syllabus = (data['syllabus'] as List)
            .map((e) => SyllabusItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (data['vault'] is List) {
        _vault = (data['vault'] as List)
            .map((e) => VaultItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      await _saveAll();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  /// Pick JSON file via FilePicker and restore
  Future<bool> pickAndImportBackupFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (files.isEmpty) return false;
      final picked = files.first;
      String? content;
      if (picked.path != null) {
        content = await File(picked.path!).readAsString();
      }
      if (content == null || content.isEmpty) return false;
      return await importBackupFromJsonString(content);
    } catch (e) {
      debugPrint('File pick error: $e');
      return false;
    }
  }

  Future<void> resetAllData() async {
    await _prefs?.clear();
    _profile = null;
    _dailyLogs = [];
    _utbkTryouts = [];
    _skdTryouts = [];
    _psikotesLogs = [];
    _samaptaLogs = [];
    _syllabus = PassingGradesRepository.defaultSyllabus();
    _vault = _defaultVaultItems();
    _streakCount = 0;
    _lastActiveDate = '';
    _streakFreezes = 1;
    _coins = 200;
    _exp = 100;
    _equippedAccessory = 'none';
    _unlockedAccessories = ['none'];
    notifyListeners();
  }
}
