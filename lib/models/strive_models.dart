import 'dart:convert';

enum IgnisMood {
  happyHype,
  angryGuilt,
  cryingFrozen,
  coachSpartan,
  burnoutDoctor,
}

class UserProfile {
  final String nickname;
  final String schoolGrade;
  final String gender; // 'Pria' or 'Wanita'
  final List<String> selectedTracks; // ['UTBK', 'TKA', 'KEDINASAN']
  final String tkaCategory; // 'Saintek' or 'Soshum'
  final String customTkaSubtest;
  final String targetPtnId;
  final String targetPtnName;
  final String targetPtnMajor;
  final double targetUtbkScore;
  final String targetKedinasanId;
  final String targetKedinasanName;
  final String targetKedinasanMajor;
  final int targetSkdScore;
  final double targetSamaptaScore;
  final String timeCapsuleLetter;
  final String timeCapsuleUnlockDate;
  final String createdAt;

  const UserProfile({
    required this.nickname,
    required this.schoolGrade,
    required this.gender,
    required this.selectedTracks,
    this.tkaCategory = 'Saintek',
    this.customTkaSubtest = '',
    required this.targetPtnId,
    required this.targetPtnName,
    required this.targetPtnMajor,
    required this.targetUtbkScore,
    required this.targetKedinasanId,
    required this.targetKedinasanName,
    required this.targetKedinasanMajor,
    required this.targetSkdScore,
    this.targetSamaptaScore = 75.0,
    required this.timeCapsuleLetter,
    this.timeCapsuleUnlockDate = '2027-05-01',
    required this.createdAt,
  });

  UserProfile copyWith({
    String? nickname,
    String? schoolGrade,
    String? gender,
    List<String>? selectedTracks,
    String? tkaCategory,
    String? customTkaSubtest,
    String? targetPtnId,
    String? targetPtnName,
    String? targetPtnMajor,
    double? targetUtbkScore,
    String? targetKedinasanId,
    String? targetKedinasanName,
    String? targetKedinasanMajor,
    int? targetSkdScore,
    double? targetSamaptaScore,
    String? timeCapsuleLetter,
    String? timeCapsuleUnlockDate,
    String? createdAt,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      schoolGrade: schoolGrade ?? this.schoolGrade,
      gender: gender ?? this.gender,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      tkaCategory: tkaCategory ?? this.tkaCategory,
      customTkaSubtest: customTkaSubtest ?? this.customTkaSubtest,
      targetPtnId: targetPtnId ?? this.targetPtnId,
      targetPtnName: targetPtnName ?? this.targetPtnName,
      targetPtnMajor: targetPtnMajor ?? this.targetPtnMajor,
      targetUtbkScore: targetUtbkScore ?? this.targetUtbkScore,
      targetKedinasanId: targetKedinasanId ?? this.targetKedinasanId,
      targetKedinasanName: targetKedinasanName ?? this.targetKedinasanName,
      targetKedinasanMajor: targetKedinasanMajor ?? this.targetKedinasanMajor,
      targetSkdScore: targetSkdScore ?? this.targetSkdScore,
      targetSamaptaScore: targetSamaptaScore ?? this.targetSamaptaScore,
      timeCapsuleLetter: timeCapsuleLetter ?? this.timeCapsuleLetter,
      timeCapsuleUnlockDate: timeCapsuleUnlockDate ?? this.timeCapsuleUnlockDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'schoolGrade': schoolGrade,
        'gender': gender,
        'selectedTracks': selectedTracks,
        'tkaCategory': tkaCategory,
        'customTkaSubtest': customTkaSubtest,
        'targetPtnId': targetPtnId,
        'targetPtnName': targetPtnName,
        'targetPtnMajor': targetPtnMajor,
        'targetUtbkScore': targetUtbkScore,
        'targetKedinasanId': targetKedinasanId,
        'targetKedinasanName': targetKedinasanName,
        'targetKedinasanMajor': targetKedinasanMajor,
        'targetSkdScore': targetSkdScore,
        'targetSamaptaScore': targetSamaptaScore,
        'timeCapsuleLetter': timeCapsuleLetter,
        'timeCapsuleUnlockDate': timeCapsuleUnlockDate,
        'createdAt': createdAt,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        nickname: json['nickname']?.toString() ?? 'Komandan',
        schoolGrade: json['schoolGrade']?.toString() ?? 'Kelas 12 SMA',
        gender: json['gender']?.toString() ?? 'Pria',
        selectedTracks: (json['selectedTracks'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ['UTBK', 'TKA', 'KEDINASAN'],
        tkaCategory: json['tkaCategory']?.toString() ?? 'Saintek',
        customTkaSubtest: json['customTkaSubtest']?.toString() ?? '',
        targetPtnId: json['targetPtnId']?.toString() ?? 'itb',
        targetPtnName:
            json['targetPtnName']?.toString() ?? 'Institut Teknologi Bandung (ITB)',
        targetPtnMajor: json['targetPtnMajor']?.toString() ??
            'STEI - Komputasi (Informatika & Sistem Informasi)',
        targetUtbkScore: (json['targetUtbkScore'] as num?)?.toDouble() ?? 745.0,
        targetKedinasanId: json['targetKedinasanId']?.toString() ?? 'stan',
        targetKedinasanName:
            json['targetKedinasanName']?.toString() ?? 'PKN STAN',
        targetKedinasanMajor: json['targetKedinasanMajor']?.toString() ??
            'D4 Akuntansi Sektor Publik',
        targetSkdScore: (json['targetSkdScore'] as num?)?.toInt() ?? 445,
        targetSamaptaScore:
            (json['targetSamaptaScore'] as num?)?.toDouble() ?? 75.0,
        timeCapsuleLetter: json['timeCapsuleLetter']?.toString() ?? '',
        timeCapsuleUnlockDate:
            json['timeCapsuleUnlockDate']?.toString() ?? '2027-05-01',
        createdAt:
            json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      );
}

class DailyStudyLog {
  final String id;
  final String date; // YYYY-MM-DD
  final String track; // 'UTBK', 'TKA', 'KEDINASAN', 'FISIK'
  final String subtestCode;
  final int minutes;
  final String fatigueLevel; // 'Semangat', 'Biasa', 'Otak/Badan Ngebul'
  final String notes;

  const DailyStudyLog({
    required this.id,
    required this.date,
    required this.track,
    required this.subtestCode,
    required this.minutes,
    required this.fatigueLevel,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'track': track,
        'subtestCode': subtestCode,
        'minutes': minutes,
        'fatigueLevel': fatigueLevel,
        'notes': notes,
      };

  factory DailyStudyLog.fromJson(Map<String, dynamic> json) => DailyStudyLog(
        id: json['id']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        track: json['track']?.toString() ?? 'UTBK',
        subtestCode: json['subtestCode']?.toString() ?? 'PK',
        minutes: (json['minutes'] as num?)?.toInt() ?? 25,
        fatigueLevel: json['fatigueLevel']?.toString() ?? 'Semangat',
        notes: json['notes']?.toString() ?? '',
      );
}

class UtbkTkaTryout {
  final String id;
  final String name;
  final String date; // YYYY-MM-DD
  final String category; // 'UTBK' or 'TKA'
  final Map<String, double> subtestScores; // e.g. {'PU': 710, 'PK': 680}

  const UtbkTkaTryout({
    required this.id,
    required this.name,
    required this.date,
    required this.category,
    required this.subtestScores,
  });

  double get averageScore {
    if (subtestScores.isEmpty) return 0.0;
    final total = subtestScores.values.fold<double>(0.0, (a, b) => a + b);
    return total / subtestScores.length;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date,
        'category': category,
        'subtestScores': subtestScores,
      };

  factory UtbkTkaTryout.fromJson(Map<String, dynamic> json) {
    final rawMap = json['subtestScores'] as Map<String, dynamic>? ?? {};
    final parsed = <String, double>{};
    rawMap.forEach((key, value) {
      parsed[key] = (value as num?)?.toDouble() ?? 0.0;
    });
    return UtbkTkaTryout(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'TryOut',
      date: json['date']?.toString() ?? '',
      category: json['category']?.toString() ?? 'UTBK',
      subtestScores: parsed,
    );
  }
}

class SkdTryout {
  final String id;
  final String name;
  final String date; // YYYY-MM-DD
  final int twk; // Ambang batas >= 65 (Max 150)
  final int tiu; // Ambang batas >= 80 (Max 175)
  final int tkp; // Ambang batas >= 166 (Max 225)

  const SkdTryout({
    required this.id,
    required this.name,
    required this.date,
    required this.twk,
    required this.tiu,
    required this.tkp,
  });

  int get totalScore => twk + tiu + tkp;
  bool get passTwk => twk >= 65;
  bool get passTiu => tiu >= 80;
  bool get passTkp => tkp >= 166;
  bool get passedAll => passTwk && passTiu && passTkp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date,
        'twk': twk,
        'tiu': tiu,
        'tkp': tkp,
      };

  factory SkdTryout.fromJson(Map<String, dynamic> json) => SkdTryout(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'TryOut SKD CAT',
        date: json['date']?.toString() ?? '',
        twk: (json['twk'] as num?)?.toInt() ?? 0,
        tiu: (json['tiu'] as num?)?.toInt() ?? 0,
        tkp: (json['tkp'] as num?)?.toInt() ?? 0,
      );
}

class PsikotesLog {
  final String id;
  final String name;
  final String date;
  final double kecerdasan; // 0-100
  final double kepribadian; // 0-100
  final double kecermatanSpeed; // Lajur/skor 0-100
  final double kecermatanAccuracy; // % 0-100
  final double kecermatanStability; // Endurance 0-100

  const PsikotesLog({
    required this.id,
    required this.name,
    required this.date,
    required this.kecerdasan,
    required this.kepribadian,
    required this.kecermatanSpeed,
    required this.kecermatanAccuracy,
    required this.kecermatanStability,
  });

  double get overallScore =>
      (kecerdasan * 0.35) +
      (kepribadian * 0.25) +
      (((kecermatanSpeed + kecermatanAccuracy + kecermatanStability) / 3.0) *
          0.40);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date,
        'kecerdasan': kecerdasan,
        'kepribadian': kepribadian,
        'kecermatanSpeed': kecermatanSpeed,
        'kecermatanAccuracy': kecermatanAccuracy,
        'kecermatanStability': kecermatanStability,
      };

  factory PsikotesLog.fromJson(Map<String, dynamic> json) => PsikotesLog(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Simulasi Psikotes',
        date: json['date']?.toString() ?? '',
        kecerdasan: (json['kecerdasan'] as num?)?.toDouble() ?? 75.0,
        kepribadian: (json['kepribadian'] as num?)?.toDouble() ?? 80.0,
        kecermatanSpeed: (json['kecermatanSpeed'] as num?)?.toDouble() ?? 75.0,
        kecermatanAccuracy:
            (json['kecermatanAccuracy'] as num?)?.toDouble() ?? 90.0,
        kecermatanStability:
            (json['kecermatanStability'] as num?)?.toDouble() ?? 80.0,
      );
}

class SamaptaLog {
  final String id;
  final String date; // YYYY-MM-DD
  final String gender; // 'Pria' or 'Wanita'
  final double lari12MenitMeters;
  final int pullUpOrChinningReps;
  final int sitUpReps;
  final int pushUpReps;
  final double shuttleRunSeconds;
  final double renang25mSeconds;
  final double scoreA;
  final double scoreB1;
  final double scoreB2;
  final double scoreB3;
  final double scoreB4;
  final double finalScore;

  const SamaptaLog({
    required this.id,
    required this.date,
    required this.gender,
    required this.lari12MenitMeters,
    required this.pullUpOrChinningReps,
    required this.sitUpReps,
    required this.pushUpReps,
    required this.shuttleRunSeconds,
    required this.renang25mSeconds,
    required this.scoreA,
    required this.scoreB1,
    required this.scoreB2,
    required this.scoreB3,
    required this.scoreB4,
    required this.finalScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'gender': gender,
        'lari12MenitMeters': lari12MenitMeters,
        'pullUpOrChinningReps': pullUpOrChinningReps,
        'sitUpReps': sitUpReps,
        'pushUpReps': pushUpReps,
        'shuttleRunSeconds': shuttleRunSeconds,
        'renang25mSeconds': renang25mSeconds,
        'scoreA': scoreA,
        'scoreB1': scoreB1,
        'scoreB2': scoreB2,
        'scoreB3': scoreB3,
        'scoreB4': scoreB4,
        'finalScore': finalScore,
      };

  factory SamaptaLog.fromJson(Map<String, dynamic> json) => SamaptaLog(
        id: json['id']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        gender: json['gender']?.toString() ?? 'Pria',
        lari12MenitMeters:
            (json['lari12MenitMeters'] as num?)?.toDouble() ?? 2400.0,
        pullUpOrChinningReps:
            (json['pullUpOrChinningReps'] as num?)?.toInt() ?? 8,
        sitUpReps: (json['sitUpReps'] as num?)?.toInt() ?? 30,
        pushUpReps: (json['pushUpReps'] as num?)?.toInt() ?? 30,
        shuttleRunSeconds:
            (json['shuttleRunSeconds'] as num?)?.toDouble() ?? 17.5,
        renang25mSeconds:
            (json['renang25mSeconds'] as num?)?.toDouble() ?? 28.0,
        scoreA: (json['scoreA'] as num?)?.toDouble() ?? 65.0,
        scoreB1: (json['scoreB1'] as num?)?.toDouble() ?? 65.0,
        scoreB2: (json['scoreB2'] as num?)?.toDouble() ?? 70.0,
        scoreB3: (json['scoreB3'] as num?)?.toDouble() ?? 70.0,
        scoreB4: (json['scoreB4'] as num?)?.toDouble() ?? 72.0,
        finalScore: (json['finalScore'] as num?)?.toDouble() ?? 67.1,
      );
}

class SyllabusItem {
  final String id;
  final String track; // 'UTBK', 'TKA', 'SKD', 'PSIKOTES', 'FISIK'
  final String subtest;
  final String topic;
  final int status; // 0: Merah, 1: Kuning, 2: Hijau

  const SyllabusItem({
    required this.id,
    required this.track,
    required this.subtest,
    required this.topic,
    this.status = 0,
  });

  SyllabusItem copyWith({int? status}) => SyllabusItem(
        id: id,
        track: track,
        subtest: subtest,
        topic: topic,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'track': track,
        'subtest': subtest,
        'topic': topic,
        'status': status,
      };

  factory SyllabusItem.fromJson(Map<String, dynamic> json) => SyllabusItem(
        id: json['id']?.toString() ?? '',
        track: json['track']?.toString() ?? 'UTBK',
        subtest: json['subtest']?.toString() ?? 'PU',
        topic: json['topic']?.toString() ?? '',
        status: (json['status'] as num?)?.toInt() ?? 0,
      );
}

class VaultItem {
  final String id;
  final String title;
  final String category; // 'UTBK', 'TKA', 'SKD', 'FISIK'
  final String contentOrUrl;
  final String tag;
  final String createdAt;
  final bool isPinned;

  const VaultItem({
    required this.id,
    required this.title,
    required this.category,
    required this.contentOrUrl,
    required this.tag,
    required this.createdAt,
    this.isPinned = false,
  });

  VaultItem copyWith({bool? isPinned}) => VaultItem(
        id: id,
        title: title,
        category: category,
        contentOrUrl: contentOrUrl,
        tag: tag,
        createdAt: createdAt,
        isPinned: isPinned ?? this.isPinned,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'contentOrUrl': contentOrUrl,
        'tag': tag,
        'createdAt': createdAt,
        'isPinned': isPinned,
      };

  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        category: json['category']?.toString() ?? 'UTBK',
        contentOrUrl: json['contentOrUrl']?.toString() ?? '',
        tag: json['tag']?.toString() ?? 'Rumus & Catatan',
        createdAt: json['createdAt']?.toString() ?? '',
        isPinned: json['isPinned'] == true,
      );
}

class MascotAccessory {
  final String id;
  final String name;
  final String description;
  final int costCoins;
  final String badgeText;

  const MascotAccessory({
    required this.id,
    required this.name,
    required this.description,
    required this.costCoins,
    required this.badgeText,
  });
}

class SamaptaPrescription {
  final String itemTitle;
  final String statusZone; // 'Zona Bahaya', 'Zona Waspada', 'Zona Aman / Elite'
  final String deficitText;
  final String weeklyDrill;
  final double currentScore;

  const SamaptaPrescription({
    required this.itemTitle,
    required this.statusZone,
    required this.deficitText,
    required this.weeklyDrill,
    required this.currentScore,
  });
}

String encodeJsonList<T>(List<T> items, Map<String, dynamic> Function(T) toJson) {
  return jsonEncode(items.map(toJson).toList());
}
