import '../models/strive_models.dart';

class MajorPassingGrade {
  final String id;
  final String name;
  final String category; // 'Saintek', 'Soshum', 'Kedinasan'
  final int targetScore; // UTBK (0-1000) or SKD (0-550)
  final String tier;
  final double targetSamapta;

  const MajorPassingGrade({
    required this.id,
    required this.name,
    required this.category,
    required this.targetScore,
    required this.tier,
    this.targetSamapta = 75.0,
  });
}

class InstitutionData {
  final String id;
  final String name;
  final String shortName;
  final bool isKedinasan;
  final List<MajorPassingGrade> majors;

  const InstitutionData({
    required this.id,
    required this.name,
    required this.shortName,
    required this.isKedinasan,
    required this.majors,
  });
}

class SubtestMeta {
  final String code;
  final String name;
  final String track; // 'UTBK', 'TKA_SAINTEK', 'TKA_SOSHUM', 'SKD', 'PSIKOTES', 'FISIK'
  final double maxScore;
  final double passingScore;

  const SubtestMeta({
    required this.code,
    required this.name,
    required this.track,
    required this.maxScore,
    required this.passingScore,
  });
}

class PassingGradesRepository {
  static const List<SubtestMeta> utbkSubtests = [
    SubtestMeta(code: 'PU', name: 'Penalaran Umum', track: 'UTBK', maxScore: 1000, passingScore: 700),
    SubtestMeta(code: 'PPU', name: 'Pengetahuan & Pemahaman Umum', track: 'UTBK', maxScore: 1000, passingScore: 680),
    SubtestMeta(code: 'PBM', name: 'Pemahaman Bacaan & Menulis', track: 'UTBK', maxScore: 1000, passingScore: 690),
    SubtestMeta(code: 'PK', name: 'Pengetahuan Kuantitatif', track: 'UTBK', maxScore: 1000, passingScore: 710),
    SubtestMeta(code: 'LBI', name: 'Literasi Bahasa Indonesia', track: 'UTBK', maxScore: 1000, passingScore: 705),
    SubtestMeta(code: 'LBE', name: 'Literasi Bahasa Inggris', track: 'UTBK', maxScore: 1000, passingScore: 700),
    SubtestMeta(code: 'PM', name: 'Penalaran Matematika', track: 'UTBK', maxScore: 1000, passingScore: 715),
  ];

  static const List<SubtestMeta> tkaSaintekSubtests = [
    SubtestMeta(code: 'MTK_L', name: 'Matematika Lanjut', track: 'TKA_SAINTEK', maxScore: 1000, passingScore: 710),
    SubtestMeta(code: 'FIS', name: 'Fisika', track: 'TKA_SAINTEK', maxScore: 1000, passingScore: 700),
    SubtestMeta(code: 'KIM', name: 'Kimia', track: 'TKA_SAINTEK', maxScore: 1000, passingScore: 700),
    SubtestMeta(code: 'BIO', name: 'Biologi', track: 'TKA_SAINTEK', maxScore: 1000, passingScore: 700),
  ];

  static const List<SubtestMeta> tkaSoshumSubtests = [
    SubtestMeta(code: 'EKO', name: 'Ekonomi', track: 'TKA_SOSHUM', maxScore: 1000, passingScore: 710),
    SubtestMeta(code: 'GEO', name: 'Geografi', track: 'TKA_SOSHUM', maxScore: 1000, passingScore: 695),
    SubtestMeta(code: 'SOS', name: 'Sosiologi', track: 'TKA_SOSHUM', maxScore: 1000, passingScore: 700),
    SubtestMeta(code: 'SEJ', name: 'Sejarah', track: 'TKA_SOSHUM', maxScore: 1000, passingScore: 695),
  ];

  static const List<SubtestMeta> skdSubtests = [
    SubtestMeta(code: 'TWK', name: 'Tes Wawasan Kebangsaan', track: 'SKD', maxScore: 150, passingScore: 65),
    SubtestMeta(code: 'TIU', name: 'Tes Intelegensia Umum', track: 'SKD', maxScore: 175, passingScore: 80),
    SubtestMeta(code: 'TKP', name: 'Tes Karakteristik Pribadi', track: 'SKD', maxScore: 225, passingScore: 166),
  ];

  static const List<MascotAccessory> shopAccessories = [
    MascotAccessory(
      id: 'none',
      name: 'Ignis Original',
      description: 'Mode standar sang Phoenix-Harimau penjaga disiplin.',
      costCoins: 0,
      badgeText: 'DEFAULT',
    ),
    MascotAccessory(
      id: 'kacamata_ambis',
      name: 'Kacamata Ambis STEI/FK',
      description: 'Kacamata taktis anti-silau buat babat soal PK & PM 1000 poin.',
      costCoins: 150,
      badgeText: '+10% HYPE',
    ),
    MascotAccessory(
      id: 'baret_taruna',
      name: 'Baret Merah Taruna',
      description: 'Baret kehormatan pejuang Sekolah Kedinasan & Samapta.',
      costCoins: 250,
      badgeText: 'KOMANDAN',
    ),
    MascotAccessory(
      id: 'headband_spartan',
      name: 'Spartan Tactical Band',
      description: 'Ikat kepala tempur Pull-up 17x & Lari 3200m.',
      costCoins: 200,
      badgeText: 'FISIK ELITE',
    ),
    MascotAccessory(
      id: 'mahkota_sepuh',
      name: 'Mahkota Sepuh 2027',
      description: 'Mahkota emas murni untuk penakluk Boss PTN & Kedinasan.',
      costCoins: 450,
      badgeText: 'SEPUH LEGEND',
    ),
  ];

  static const List<InstitutionData> ptnList = [
    InstitutionData(
      id: 'itb',
      name: 'Institut Teknologi Bandung (ITB)',
      shortName: 'ITB',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'itb-stei-k', name: 'STEI - Komputasi (Informatika & Sistem Informasi)', category: 'Saintek', targetScore: 745, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'itb-stei-r', name: 'STEI - Rekayasa (Elektro, Tenaga Listrik, Telekomunikasi)', category: 'Saintek', targetScore: 710, tier: 'Ketat'),
        MajorPassingGrade(id: 'itb-ftmd', name: 'Fakultas Teknik Mesin dan Dirgantara (FTMD)', category: 'Saintek', targetScore: 715, tier: 'Ketat'),
        MajorPassingGrade(id: 'itb-fti', name: 'Fakultas Teknologi Industri (FTI)', category: 'Saintek', targetScore: 720, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'itb-ftsl', name: 'Fakultas Teknik Sipil dan Lingkungan (FTSL)', category: 'Saintek', targetScore: 695, tier: 'Ketat'),
        MajorPassingGrade(id: 'itb-sbm', name: 'Sekolah Bisnis dan Manajemen (SBM)', category: 'Soshum', targetScore: 725, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'itb-fsrd', name: 'Fakultas Seni Rupa dan Desain (FSRD)', category: 'Soshum', targetScore: 685, tier: 'Ketat'),
      ],
    ),
    InstitutionData(
      id: 'ui',
      name: 'Universitas Indonesia (UI)',
      shortName: 'UI',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'ui-ilkom', name: 'Ilmu Komputer', category: 'Saintek', targetScore: 740, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ui-si', name: 'Sistem Informasi', category: 'Saintek', targetScore: 725, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ui-fk', name: 'Pendidikan Dokter', category: 'Saintek', targetScore: 755, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ui-ti', name: 'Teknik Industri', category: 'Saintek', targetScore: 715, tier: 'Ketat'),
        MajorPassingGrade(id: 'ui-te', name: 'Teknik Elektro', category: 'Saintek', targetScore: 700, tier: 'Ketat'),
        MajorPassingGrade(id: 'ui-hukum', name: 'Ilmu Hukum', category: 'Soshum', targetScore: 715, tier: 'Ketat'),
        MajorPassingGrade(id: 'ui-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 720, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ui-akuntansi', name: 'Akuntansi', category: 'Soshum', targetScore: 725, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ui-psikologi', name: 'Psikologi', category: 'Soshum', targetScore: 715, tier: 'Ketat'),
        MajorPassingGrade(id: 'ui-hi', name: 'Ilmu Hubungan Internasional', category: 'Soshum', targetScore: 730, tier: 'Sangat Ketat'),
      ],
    ),
    InstitutionData(
      id: 'ugm',
      name: 'Universitas Gadjah Mada (UGM)',
      shortName: 'UGM',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'ugm-ilkom', name: 'Ilmu Komputer', category: 'Saintek', targetScore: 725, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ugm-ti', name: 'Teknologi Informasi', category: 'Saintek', targetScore: 720, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ugm-fk', name: 'Kedokteran', category: 'Saintek', targetScore: 750, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ugm-ts', name: 'Teknik Sipil', category: 'Saintek', targetScore: 700, tier: 'Ketat'),
        MajorPassingGrade(id: 'ugm-psikologi', name: 'Psikologi', category: 'Soshum', targetScore: 715, tier: 'Ketat'),
        MajorPassingGrade(id: 'ugm-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 720, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ugm-hukum', name: 'Hukum', category: 'Soshum', targetScore: 705, tier: 'Ketat'),
        MajorPassingGrade(id: 'ugm-ilkom-sos', name: 'Ilmu Komunikasi', category: 'Soshum', targetScore: 710, tier: 'Ketat'),
      ],
    ),
    InstitutionData(
      id: 'its',
      name: 'Institut Teknologi Sepuluh Nopember (ITS)',
      shortName: 'ITS',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'its-if', name: 'Teknik Informatika', category: 'Saintek', targetScore: 720, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'its-si', name: 'Sistem Informasi', category: 'Saintek', targetScore: 705, tier: 'Ketat'),
        MajorPassingGrade(id: 'its-rpl', name: 'Rekayasa Perangkat Lunak (RPL)', category: 'Saintek', targetScore: 695, tier: 'Ketat'),
        MajorPassingGrade(id: 'its-ai', name: 'Rekayasa Kecerdasan Artifisial', category: 'Saintek', targetScore: 700, tier: 'Ketat'),
        MajorPassingGrade(id: 'its-te', name: 'Teknik Elektro', category: 'Saintek', targetScore: 685, tier: 'Ketat'),
        MajorPassingGrade(id: 'its-ti', name: 'Teknik Industri', category: 'Saintek', targetScore: 695, tier: 'Ketat'),
        MajorPassingGrade(id: 'its-mb', name: 'Manajemen Bisnis', category: 'Soshum', targetScore: 675, tier: 'Sedang'),
      ],
    ),
    InstitutionData(
      id: 'unpad',
      name: 'Universitas Padjadjaran (Unpad)',
      shortName: 'Unpad',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'unpad-if', name: 'Teknik Informatika', category: 'Saintek', targetScore: 710, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'unpad-fk', name: 'Pendidikan Dokter', category: 'Saintek', targetScore: 735, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'unpad-farmasi', name: 'Farmasi', category: 'Saintek', targetScore: 700, tier: 'Ketat'),
        MajorPassingGrade(id: 'unpad-psikologi', name: 'Psikologi', category: 'Saintek', targetScore: 710, tier: 'Ketat'),
        MajorPassingGrade(id: 'unpad-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 705, tier: 'Ketat'),
        MajorPassingGrade(id: 'unpad-hukum', name: 'Ilmu Hukum', category: 'Soshum', targetScore: 690, tier: 'Ketat'),
        MajorPassingGrade(id: 'unpad-ilkom', name: 'Ilmu Komunikasi', category: 'Soshum', targetScore: 705, tier: 'Ketat'),
        MajorPassingGrade(id: 'unpad-bisdig', name: 'Bisnis Digital', category: 'Soshum', targetScore: 710, tier: 'Sangat Ketat'),
      ],
    ),
    InstitutionData(
      id: 'upi',
      name: 'Universitas Pendidikan Indonesia (UPI)',
      shortName: 'UPI',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'upi-ilkom', name: 'Ilmu Komputer', category: 'Saintek', targetScore: 670, tier: 'Ketat'),
        MajorPassingGrade(id: 'upi-rpl', name: 'Rekayasa Perangkat Lunak (RPL)', category: 'Saintek', targetScore: 660, tier: 'Ketat'),
        MajorPassingGrade(id: 'upi-pst', name: 'Pendidikan Sistem dan Teknologi Informasi (Kampus Purwakarta)', category: 'Saintek', targetScore: 635, tier: 'Sedang'),
        MajorPassingGrade(id: 'upi-mekatronika', name: 'Sistem Telekomunikasi (Kampus Purwakarta)', category: 'Saintek', targetScore: 625, tier: 'Sedang'),
        MajorPassingGrade(id: 'upi-psikologi', name: 'Psikologi', category: 'Soshum', targetScore: 675, tier: 'Ketat'),
        MajorPassingGrade(id: 'upi-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 665, tier: 'Ketat'),
      ],
    ),
    InstitutionData(
      id: 'ipb',
      name: 'IPB University (Institut Pertanian Bogor)',
      shortName: 'IPB',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'ipb-ilkom', name: 'Ilmu Komputer', category: 'Saintek', targetScore: 705, tier: 'Ketat'),
        MajorPassingGrade(id: 'ipb-stat', name: 'Statistika dan Sains Data', category: 'Saintek', targetScore: 700, tier: 'Ketat'),
        MajorPassingGrade(id: 'ipb-tp', name: 'Teknologi Pangan', category: 'Saintek', targetScore: 690, tier: 'Ketat'),
        MajorPassingGrade(id: 'ipb-fk', name: 'Kedokteran', category: 'Saintek', targetScore: 725, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ipb-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 685, tier: 'Ketat'),
        MajorPassingGrade(id: 'ipb-bisnis', name: 'Bisnis', category: 'Soshum', targetScore: 680, tier: 'Ketat'),
      ],
    ),
    InstitutionData(
      id: 'undip',
      name: 'Universitas Diponegoro (Undip)',
      shortName: 'Undip',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'undip-if', name: 'Informatika', category: 'Saintek', targetScore: 700, tier: 'Ketat'),
        MajorPassingGrade(id: 'undip-tk', name: 'Teknik Komputer', category: 'Saintek', targetScore: 680, tier: 'Ketat'),
        MajorPassingGrade(id: 'undip-fk', name: 'Kedokteran', category: 'Saintek', targetScore: 730, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'undip-hukum', name: 'Hukum', category: 'Soshum', targetScore: 685, tier: 'Ketat'),
        MajorPassingGrade(id: 'undip-psikologi', name: 'Psikologi', category: 'Soshum', targetScore: 690, tier: 'Ketat'),
        MajorPassingGrade(id: 'undip-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 695, tier: 'Ketat'),
      ],
    ),
    InstitutionData(
      id: 'ub',
      name: 'Universitas Brawijaya (UB)',
      shortName: 'UB',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'ub-tif', name: 'Teknik Informatika', category: 'Saintek', targetScore: 695, tier: 'Ketat'),
        MajorPassingGrade(id: 'ub-si', name: 'Sistem Informasi', category: 'Saintek', targetScore: 685, tier: 'Ketat'),
        MajorPassingGrade(id: 'ub-ti', name: 'Teknologi Informasi', category: 'Saintek', targetScore: 675, tier: 'Ketat'),
        MajorPassingGrade(id: 'ub-fk', name: 'Kedokteran', category: 'Saintek', targetScore: 725, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'ub-hukum', name: 'Ilmu Hukum', category: 'Soshum', targetScore: 675, tier: 'Ketat'),
        MajorPassingGrade(id: 'ub-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 685, tier: 'Ketat'),
      ],
    ),
    InstitutionData(
      id: 'unair',
      name: 'Universitas Airlangga (Unair)',
      shortName: 'Unair',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'unair-fk', name: 'Kedokteran', category: 'Saintek', targetScore: 740, tier: 'Sangat Ketat'),
        MajorPassingGrade(id: 'unair-si', name: 'Sistem Informasi', category: 'Saintek', targetScore: 685, tier: 'Ketat'),
        MajorPassingGrade(id: 'unair-sd', name: 'Teknologi Sains Data', category: 'Saintek', targetScore: 680, tier: 'Ketat'),
        MajorPassingGrade(id: 'unair-psikologi', name: 'Psikologi', category: 'Soshum', targetScore: 690, tier: 'Ketat'),
        MajorPassingGrade(id: 'unair-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 695, tier: 'Ketat'),
      ],
    ),
    InstitutionData(
      id: 'unsika',
      name: 'Universitas Singaperbangsa Karawang (Unsika)',
      shortName: 'Unsika',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'unsika-if', name: 'Informatika', category: 'Saintek', targetScore: 625, tier: 'Sedang'),
        MajorPassingGrade(id: 'unsika-si', name: 'Sistem Informasi', category: 'Saintek', targetScore: 615, tier: 'Sedang'),
        MajorPassingGrade(id: 'unsika-ti', name: 'Teknik Industri', category: 'Saintek', targetScore: 610, tier: 'Sedang'),
        MajorPassingGrade(id: 'unsika-manajemen', name: 'Manajemen', category: 'Soshum', targetScore: 615, tier: 'Sedang'),
        MajorPassingGrade(id: 'unsika-hukum', name: 'Ilmu Hukum', category: 'Soshum', targetScore: 605, tier: 'Sedang'),
      ],
    ),
    InstitutionData(
      id: 'telkom',
      name: 'Telkom University (Tel-U)',
      shortName: 'Tel-U',
      isKedinasan: false,
      majors: [
        MajorPassingGrade(id: 'telu-if', name: 'S1 Informatika', category: 'Saintek', targetScore: 650, tier: 'Ketat'),
        MajorPassingGrade(id: 'telu-rpl', name: 'S1 Rekayasa Perangkat Lunak (RPL)', category: 'Saintek', targetScore: 640, tier: 'Sedang'),
        MajorPassingGrade(id: 'telu-si', name: 'S1 Sistem Informasi', category: 'Saintek', targetScore: 635, tier: 'Sedang'),
        MajorPassingGrade(id: 'telu-ds', name: 'S1 Sains Data', category: 'Saintek', targetScore: 635, tier: 'Sedang'),
        MajorPassingGrade(id: 'telu-mbti', name: 'S1 Manajemen Bisnis Telekomunikasi & Informatika (MBTI)', category: 'Soshum', targetScore: 640, tier: 'Sedang'),
      ],
    ),
  ];

  static const List<InstitutionData> kedinasanList = [
    InstitutionData(
      id: 'stan',
      name: 'Politeknik Keuangan Negara STAN (PKN STAN)',
      shortName: 'PKN STAN',
      isKedinasan: true,
      majors: [
        MajorPassingGrade(id: 'stan-asp', name: 'D4 Akuntansi Sektor Publik', category: 'Kedinasan', targetScore: 452, tier: 'Sangat Ketat', targetSamapta: 72.0),
        MajorPassingGrade(id: 'stan-mp', name: 'D4 Manajemen Keuangan Negara', category: 'Kedinasan', targetScore: 446, tier: 'Sangat Ketat', targetSamapta: 72.0),
        MajorPassingGrade(id: 'stan-ma', name: 'D4 Manajemen Aset Publik', category: 'Kedinasan', targetScore: 440, tier: 'Ketat', targetSamapta: 72.0),
      ],
    ),
    InstitutionData(
      id: 'stis',
      name: 'Politeknik Statistika STIS (BPS)',
      shortName: 'STIS',
      isKedinasan: true,
      majors: [
        MajorPassingGrade(id: 'stis-ks', name: 'D4 Komputasi Statistik (Sains Data & Sistem Informasi)', category: 'Kedinasan', targetScore: 458, tier: 'Sangat Ketat', targetSamapta: 70.0),
        MajorPassingGrade(id: 'stis-d4stat', name: 'D4 Statistika', category: 'Kedinasan', targetScore: 450, tier: 'Sangat Ketat', targetSamapta: 70.0),
        MajorPassingGrade(id: 'stis-d3stat', name: 'D3 Statistika', category: 'Kedinasan', targetScore: 435, tier: 'Ketat', targetSamapta: 70.0),
      ],
    ),
    InstitutionData(
      id: 'ipdn',
      name: 'Institut Pemerintahan Dalam Negeri (IPDN)',
      shortName: 'IPDN',
      isKedinasan: true,
      majors: [
        MajorPassingGrade(id: 'ipdn-pp', name: 'D4 Politik Pemerintahan & Manajemen Kepemerintahan', category: 'Kedinasan', targetScore: 438, tier: 'Sangat Ketat', targetSamapta: 78.0),
        MajorPassingGrade(id: 'ipdn-kp', name: 'D4 Keuangan Publik & Pembangunan Ekonomi Daerah', category: 'Kedinasan', targetScore: 432, tier: 'Ketat', targetSamapta: 78.0),
      ],
    ),
    InstitutionData(
      id: 'stin',
      name: 'Sekolah Tinggi Intelijen Negara (STIN - BIN)',
      shortName: 'STIN',
      isKedinasan: true,
      majors: [
        MajorPassingGrade(id: 'stin-agen', name: 'S1 Agen Intelijen', category: 'Kedinasan', targetScore: 445, tier: 'Sangat Ketat', targetSamapta: 82.0),
        MajorPassingGrade(id: 'stin-cyber', name: 'S1 Teknologi & Siber Intelijen', category: 'Kedinasan', targetScore: 450, tier: 'Sangat Ketat', targetSamapta: 80.0),
      ],
    ),
    InstitutionData(
      id: 'ssn',
      name: 'Politeknik Siber dan Sandi Negara (Poltek SSN - BSSN)',
      shortName: 'Poltek SSN',
      isKedinasan: true,
      majors: [
        MajorPassingGrade(id: 'ssn-rk', name: 'D4 Rekayasa Keamanan Siber (Cyber Security)', category: 'Kedinasan', targetScore: 448, tier: 'Sangat Ketat', targetSamapta: 75.0),
        MajorPassingGrade(id: 'ssn-rks', name: 'D4 Rekayasa Kriptografi', category: 'Kedinasan', targetScore: 442, tier: 'Ketat', targetSamapta: 75.0),
        MajorPassingGrade(id: 'ssn-rplk', name: 'D4 Rekayasa Perangkat Keras Kriptografi', category: 'Kedinasan', targetScore: 436, tier: 'Ketat', targetSamapta: 75.0),
      ],
    ),
    InstitutionData(
      id: 'poltekip',
      name: 'Poltekip & Poltekim (Kemenkumham)',
      shortName: 'Poltekip/Im',
      isKedinasan: true,
      majors: [
        MajorPassingGrade(id: 'poltekim-im', name: 'D4 Administrasi Keimigrasian (Poltekim)', category: 'Kedinasan', targetScore: 438, tier: 'Sangat Ketat', targetSamapta: 76.0),
        MajorPassingGrade(id: 'poltekip-mp', name: 'D4 Manajemen Pemasyarakatan (Poltekip)', category: 'Kedinasan', targetScore: 428, tier: 'Ketat', targetSamapta: 76.0),
      ],
    ),
    InstitutionData(
      id: 'kemenhub',
      name: 'Sekolah Kedinasan Kemenhub (PTDI-STTD / PPI / Poltekbang)',
      shortName: 'Kemenhub',
      isKedinasan: true,
      majors: [
        MajorPassingGrade(id: 'sttd-td', name: 'D4 Transportasi Darat (PTDI-STTD)', category: 'Kedinasan', targetScore: 425, tier: 'Ketat', targetSamapta: 74.0),
        MajorPassingGrade(id: 'ppi-ka', name: 'D3/D4 Teknologi Perkeretaapian (PPI Madiun)', category: 'Kedinasan', targetScore: 422, tier: 'Ketat', targetSamapta: 74.0),
        MajorPassingGrade(id: 'poltekbang-ll', name: 'D3 Pemandu Lalu Lintas Udara / ATC (Poltekbang)', category: 'Kedinasan', targetScore: 430, tier: 'Ketat', targetSamapta: 74.0),
      ],
    ),
  ];

  static List<SyllabusItem> defaultSyllabus() {
    return const [
      // UTBK
      SyllabusItem(id: 'syl-pu-1', track: 'UTBK', subtest: 'PU', topic: 'Logika Deduktif, Silogisme & Ekuivalensi Logis', status: 2),
      SyllabusItem(id: 'syl-pu-2', track: 'UTBK', subtest: 'PU', topic: 'Penalaran Kuantitatif: Deret, Pola Bilangan & Grafik', status: 1),
      SyllabusItem(id: 'syl-ppu-1', track: 'UTBK', subtest: 'PPU', topic: 'Makna Kata, Sinonim Kontekstual & Kepaduan Paragraf', status: 2),
      SyllabusItem(id: 'syl-pbm-1', track: 'UTBK', subtest: 'PBM', topic: 'PUEBI/EYD V, Kalimat Efektif & Kata Baku', status: 1),
      SyllabusItem(id: 'syl-pk-1', track: 'UTBK', subtest: 'PK', topic: 'Aljabar, Fungsi Kuadrat & Sistem Persamaan', status: 1),
      SyllabusItem(id: 'syl-pk-2', track: 'UTBK', subtest: 'PK', topic: 'Geometri Bidang, Ruang & Peluang Kombinatorika', status: 0),
      SyllabusItem(id: 'syl-lbi-1', track: 'UTBK', subtest: 'LBI', topic: 'Inferensi Teks Panjang, Fakta vs Opini & Gagasan Utama', status: 2),
      SyllabusItem(id: 'syl-lbe-1', track: 'UTBK', subtest: 'LBE', topic: 'Author Tone, Restatement, Inference & Thread Reading', status: 1),
      SyllabusItem(id: 'syl-pm-1', track: 'UTBK', subtest: 'PM', topic: 'Pemodelan Matematika Kontekstual & Aritmetika Sosial', status: 1),
      SyllabusItem(id: 'syl-pm-2', track: 'UTBK', subtest: 'PM', topic: 'Barisan, Deret & Optimasi Bangun Ruang', status: 0),

      // TKA
      SyllabusItem(id: 'syl-tka-1', track: 'TKA', subtest: 'MTK_L', topic: 'Kalkulus: Limit, Turunan, Integral &Aplikasi', status: 1),
      SyllabusItem(id: 'syl-tka-2', track: 'TKA', subtest: 'MTK_L', topic: 'Matriks, Vektor, Polinomial & Trigonometri Analitik', status: 0),
      SyllabusItem(id: 'syl-tka-3', track: 'TKA', subtest: 'FIS', topic: 'Mekanika Klasik, Usaha-Energi & Momentum', status: 1),
      SyllabusItem(id: 'syl-tka-4', track: 'TKA', subtest: 'FIS', topic: 'Listrik Magnet, Fisika Modern & Termodinamika', status: 0),
      SyllabusItem(id: 'syl-tka-5', track: 'TKA', subtest: 'KIM', topic: 'Stoikiometri, Laju Reaksi & Kesetimbangan Kimia', status: 1),
      SyllabusItem(id: 'syl-tka-6', track: 'TKA', subtest: 'BIO', topic: 'Biologi Sel, Genetika Molekuler & Metabolisme', status: 2),
      SyllabusItem(id: 'syl-tka-7', track: 'TKA', subtest: 'EKO', topic: 'Keseimbangan Pasar, Elastisitas & Akuntansi Dasar', status: 1),

      // SKD
      SyllabusItem(id: 'syl-skd-1', track: 'SKD', subtest: 'TWK', topic: 'Pancasila, UUD 1945, NKRI & Bhinneka Tunggal Ika', status: 2),
      SyllabusItem(id: 'syl-skd-2', track: 'SKD', subtest: 'TWK', topic: 'Integritas, Bela Negara & Nasionalisme HOTS', status: 1),
      SyllabusItem(id: 'syl-skd-3', track: 'SKD', subtest: 'TIU', topic: 'Analogi Verbal, Silogisme & Penalaran Analitis Meja Bundar', status: 2),
      SyllabusItem(id: 'syl-skd-4', track: 'SKD', subtest: 'TIU', topic: 'Hitung Cepat, Perbandingan Senilai/Berbalik & Figural 9 Kotak', status: 1),
      SyllabusItem(id: 'syl-skd-5', track: 'SKD', subtest: 'TKP', topic: 'Pelayanan Publik, Jejaring Kerja & Anti-Radikalisme (Skor 5)', status: 2),

      // PSIKOTES
      SyllabusItem(id: 'syl-psi-1', track: 'PSIKOTES', subtest: 'Kecermatan', topic: 'Pauli / Kraepelin: Stabilitas Grafik & Kecepatan > 15 Lajur', status: 1),
      SyllabusItem(id: 'syl-psi-2', track: 'PSIKOTES', subtest: 'Kecerdasan', topic: 'Tes Spasial Kubus, Wartegg & Baum Draw Test', status: 1),
      SyllabusItem(id: 'syl-psi-3', track: 'PSIKOTES', subtest: 'Kepribadian', topic: 'EPPS Konsistensi & Wawancara Mental Ideologi', status: 0),

      // FISIK / SAMAPTA
      SyllabusItem(id: 'syl-fis-1', track: 'FISIK', subtest: 'Lari 12m', topic: 'Cooper Test Lari 12 Menit Target >= 2800m (Pace < 4:15/km)', status: 1),
      SyllabusItem(id: 'syl-fis-2', track: 'FISIK', subtest: 'Pull-up', topic: 'Pull-up (Pria >= 12x) / Chinning (Wanita >= 45x) Full ROM', status: 0),
      SyllabusItem(id: 'syl-fis-3', track: 'FISIK', subtest: 'Sit-up & Push-up', topic: 'Sit-up >= 38x & Push-up >= 40x dalam 60 Detik', status: 2),
      SyllabusItem(id: 'syl-fis-4', track: 'FISIK', subtest: 'Shuttle Run', topic: 'Shuttle Run 6x10m Angka 8 <= 16.8 Detik Tanpa Terpeleset', status: 1),
    ];
  }
}

/// Official Indonesian Kedinasan & TNI/Polri Inspired Samapta Physical Calculator
class SamaptaCalculator {
  static double scoreLari12Menit(double meters, String gender) {
    final isWanita = gender.toLowerCase() == 'wanita';
    final minM = isWanita ? 1400.0 : 1800.0;
    final safeM = isWanita ? 2100.0 : 2400.0;
    final maxM = isWanita ? 2650.0 : 3200.0;

    if (meters >= maxM) return 100.0;
    if (meters <= minM) return ((meters / minM) * 25.0).clamp(5.0, 25.0);
    if (meters < safeM) {
      return 25.0 + ((meters - minM) / (safeM - minM)) * 40.0; // 25..65
    }
    return 65.0 + ((meters - safeM) / (maxM - safeM)) * 35.0; // 65..100
  }

  static double scorePullUpOrChinning(int reps, String gender) {
    final isWanita = gender.toLowerCase() == 'wanita';
    if (isWanita) {
      // Chinning Wanita: 63 reps = 100, 42 reps = 70, 20 reps = 35
      if (reps >= 63) return 100.0;
      if (reps <= 0) return 0.0;
      if (reps < 25) return (reps / 25.0) * 45.0;
      if (reps < 42) return 45.0 + ((reps - 25) / 17.0) * 25.0;
      return 70.0 + ((reps - 42) / 21.0) * 30.0;
    } else {
      // Pull-up Pria: 17x = 100, 10x = 75, 5x = 50, 3x = 35
      if (reps >= 17) return 100.0;
      if (reps <= 0) return 0.0;
      if (reps <= 5) return (reps / 5.0) * 50.0 + (reps == 3 ? 5.0 : 0.0);
      if (reps <= 10) return 50.0 + ((reps - 5) / 5.0) * 25.0;
      return 75.0 + ((reps - 10) / 7.0) * 25.0;
    }
  }

  static double scoreSitUp(int reps, String gender) {
    final isWanita = gender.toLowerCase() == 'wanita';
    final maxReps = isWanita ? 43 : 40;
    final safeReps = isWanita ? 30 : 30;
    if (reps >= maxReps) return 100.0;
    if (reps <= 0) return 0.0;
    if (reps < safeReps) return (reps / safeReps) * 70.0;
    return 70.0 + ((reps - safeReps) / (maxReps - safeReps)) * 30.0;
  }

  static double scorePushUp(int reps, String gender) {
    final isWanita = gender.toLowerCase() == 'wanita';
    final maxReps = isWanita ? 37 : 42;
    final safeReps = isWanita ? 24 : 30;
    if (reps >= maxReps) return 100.0;
    if (reps <= 0) return 0.0;
    if (reps < safeReps) return (reps / safeReps) * 70.0;
    return 70.0 + ((reps - safeReps) / (maxReps - safeReps)) * 30.0;
  }

  static double scoreShuttleRun(double seconds, String gender) {
    final isWanita = gender.toLowerCase() == 'wanita';
    final bestSec = isWanita ? 17.2 : 16.0;
    final safeSec = isWanita ? 19.2 : 17.8;
    final maxSec = isWanita ? 23.0 : 21.5;

    if (seconds <= 0) return 0.0;
    if (seconds <= bestSec) return 100.0;
    if (seconds >= maxSec) return 15.0;
    if (seconds <= safeSec) {
      return 70.0 + ((safeSec - seconds) / (safeSec - bestSec)) * 30.0;
    }
    return 15.0 + ((maxSec - seconds) / (maxSec - safeSec)) * 55.0;
  }

  static SamaptaLog createCalculatedLog({
    required String id,
    required String date,
    required String gender,
    required double lari12MenitMeters,
    required int pullUpOrChinningReps,
    required int sitUpReps,
    required int pushUpReps,
    required double shuttleRunSeconds,
    required double renang25mSeconds,
  }) {
    final sA = scoreLari12Menit(lari12MenitMeters, gender);
    final sB1 = scorePullUpOrChinning(pullUpOrChinningReps, gender);
    final sB2 = scoreSitUp(sitUpReps, gender);
    final sB3 = scorePushUp(pushUpReps, gender);
    final sB4 = scoreShuttleRun(shuttleRunSeconds, gender);
    final avgB = (sB1 + sB2 + sB3 + sB4) / 4.0;
    final finalScore = (sA + avgB) / 2.0;

    return SamaptaLog(
      id: id,
      date: date,
      gender: gender,
      lari12MenitMeters: lari12MenitMeters,
      pullUpOrChinningReps: pullUpOrChinningReps,
      sitUpReps: sitUpReps,
      pushUpReps: pushUpReps,
      shuttleRunSeconds: shuttleRunSeconds,
      renang25mSeconds: renang25mSeconds,
      scoreA: double.parse(sA.toStringAsFixed(1)),
      scoreB1: double.parse(sB1.toStringAsFixed(1)),
      scoreB2: double.parse(sB2.toStringAsFixed(1)),
      scoreB3: double.parse(sB3.toStringAsFixed(1)),
      scoreB4: double.parse(sB4.toStringAsFixed(1)),
      finalScore: double.parse(finalScore.toStringAsFixed(1)),
    );
  }

  /// Ignis Coach Diagnostic & Progressive Overload Prescription
  static List<SamaptaPrescription> diagnoseAndPrescribe({
    required String gender,
    required double lariMeters,
    required int pullOrChinReps,
    required int sitUpReps,
    required int pushUpReps,
    required double shuttleSeconds,
  }) {
    final isWanita = gender.toLowerCase() == 'wanita';
    final sA = scoreLari12Menit(lariMeters, gender);
    final sB1 = scorePullUpOrChinning(pullOrChinReps, gender);
    final sB2 = scoreSitUp(sitUpReps, gender);
    final sB3 = scorePushUp(pushUpReps, gender);
    final sB4 = scoreShuttleRun(shuttleSeconds, gender);

    final prescriptions = <SamaptaPrescription>[];

    // 1. Pull-up / Chinning Diagnostic
    final safeB1Reps = isWanita ? 42 : 10;
    final b1Label = isWanita ? 'Chinning' : 'Pull-up';
    final b1Zone = sB1 < 55
        ? 'Zona Bahaya'
        : (sB1 < 75 ? 'Zona Waspada' : 'Zona Aman / Elite');
    final b1Diff = (safeB1Reps - pullOrChinReps).clamp(0, 999);
    prescriptions.add(
      SamaptaPrescription(
        itemTitle: 'Samapta B1: $b1Label ($pullOrChinReps rep)',
        statusZone: b1Zone,
        currentScore: sB1,
        deficitText: b1Diff > 0
            ? '$b1Label kamu baru $pullOrChinReps repetisi (Skor: ${sB1.toStringAsFixed(0)} - $b1Zone). Butuh +$b1Diff repetisi lagi ke batas aman ($safeB1Reps rep)!'
            : '$b1Label sudah tembus $pullOrChinReps repetisi (Skor: ${sB1.toStringAsFixed(0)} - Zona Aman). Tingkatkan ke target skor 100!',
        weeklyDrill: pullOrChinReps < (isWanita ? 28 : 8)
            ? '• Negative Pull-up / Eccentric Chin 4x8 (turun 4 detik)\n• Dead Hang 3x45s + Scapular Pull 3x12\n• Australian Row / Inverted Row 4x15 (3x seminggu)'
            : '• Pyramid Set Pull-up (1-2-3-4-5-4-3-2-1)\n• Weighted / Pause Pull-up 4x6 + Lat Pulldown Endurance',
      ),
    );

    // 2. Lari 12 Menit (Cooper Test) Diagnostic
    final safeRun = isWanita ? 2100.0 : 2400.0;
    final runZone = sA < 55
        ? 'Zona Bahaya'
        : (sA < 75 ? 'Zona Waspada' : 'Zona Aman / Elite');
    final runDiff = (safeRun - lariMeters).clamp(0.0, 5000.0).toInt();
    prescriptions.add(
      SamaptaPrescription(
        itemTitle: 'Samapta A: Lari 12 Menit (${lariMeters.toInt()} m)',
        statusZone: runZone,
        currentScore: sA,
        deficitText: runDiff > 0
            ? 'Jarak lari 12 menit baru ${lariMeters.toInt()}m (Skor: ${sA.toStringAsFixed(0)} - $runZone). Defisit -$runDiff meter dari batas aman ${safeRun.toInt()}m!'
            : 'VO2Max Mantap! Lari ${lariMeters.toInt()}m (Skor: ${sA.toStringAsFixed(0)}). Pertahankan pace menuju ${isWanita ? 2650 : 3200}m!',
        weeklyDrill: lariMeters < safeRun
            ? '• Interval 400m x 6 (Pace target 1:35/putaran, rest 90s)\n• Easy Run Zone 2 selama 30 menit (3x seminggu)\n• Tempo Run 20 menit + Drill Angkat Paha (High Knees)'
            : '• VO2Max Repeats 800m x 5 (Pace 4:00/km)\n• Long Run 45 menit Minggu pagi untuk daya tahan jantung',
      ),
    );

    // 3. Shuttle Run 6x10m Diagnostic
    final safeShuttle = isWanita ? 19.0 : 17.5;
    final shuttleZone = sB4 < 55
        ? 'Zona Bahaya'
        : (sB4 < 75 ? 'Zona Waspada' : 'Zona Aman / Elite');
    final shuttleDiff = (shuttleSeconds - safeShuttle);
    prescriptions.add(
      SamaptaPrescription(
        itemTitle: 'Samapta B4: Shuttle Run (${shuttleSeconds.toStringAsFixed(1)} dtk)',
        statusZone: shuttleZone,
        currentScore: sB4,
        deficitText: shuttleDiff > 0
            ? 'Shuttle Run ${shuttleSeconds.toStringAsFixed(1)}s (Skor: ${sB4.toStringAsFixed(0)} - $shuttleZone). Harus pangkas -${shuttleDiff.toStringAsFixed(1)} detik ke bawah ${safeShuttle}s!'
            : 'Kelincahan Gesit! Shuttle Run ${shuttleSeconds.toStringAsFixed(1)}s (Skor: ${sB4.toStringAsFixed(0)}). Jaga traksi sepatu & titik tumpu!',
        weeklyDrill: shuttleSeconds > (isWanita ? 19.2 : 18.0)
            ? '• Agility Cone Drill Angka 8 (5 set x 6x10m)\n• Ankle Plyometrics, Squat Jump 3x15 & Low Center-of-Gravity Turn\n• Latihan pengereman langkah terakhir sebelum tiang'
            : '• Explosive First-Step Sprint 10m x 8\n• Lateral Bounds & Single-Leg Stability Hops',
      ),
    );

    // 4. Sit-up & Push-up Core Endurance
    final coreAvg = (sB2 + sB3) / 2.0;
    final coreZone = coreAvg < 55
        ? 'Zona Bahaya'
        : (coreAvg < 75 ? 'Zona Waspada' : 'Zona Aman / Elite');
    prescriptions.add(
      SamaptaPrescription(
        itemTitle: 'Samapta B2 & B3: Sit-up ($sitUpReps) & Push-up ($pushUpReps)',
        statusZone: coreZone,
        currentScore: coreAvg,
        deficitText: coreAvg < 70
            ? 'Skor Sit-up (${sB2.toStringAsFixed(0)}) & Push-up (${sB3.toStringAsFixed(0)}) masih butuh ledakan stamina otot 60 detik!'
            : 'Stamina Core & Upper Body solid (Rata-rata Skor: ${coreAvg.toStringAsFixed(0)})!',
        weeklyDrill: coreAvg < 70
            ? '• EMOM (Every Minute on the Minute) 15 Push-up + 15 Sit-up x 8 menit\n• Plank 3x60s + Diamond Push-up 3x12 + Russian Twist 3x25'
            : '• Speed Burst 30 detik Max Reps x 4 set untuk mengunci 40+ repetisi/menit',
      ),
    );

    return prescriptions;
  }
}
