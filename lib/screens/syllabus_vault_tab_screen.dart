import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/strive_models.dart';
import '../services/storage_service.dart';
import '../widgets/ignis_mascot_widget.dart';
import '../widgets/strive_3d_button.dart';
import '../widgets/strive_theme.dart';

class SyllabusVaultTabScreen extends StatefulWidget {
  const SyllabusVaultTabScreen({super.key});

  @override
  State<SyllabusVaultTabScreen> createState() => _SyllabusVaultTabScreenState();
}

class _SyllabusVaultTabScreenState extends State<SyllabusVaultTabScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedSyllabusTrack = 'Semua';

  // Add Syllabus Controllers
  final _newSylSubtestCtrl = TextEditingController(text: 'PK');
  final _newSylTopicCtrl = TextEditingController();

  // Add Vault Controllers
  String _vaultCategory = 'UTBK';
  final _vaultTitleCtrl = TextEditingController();
  final _vaultContentCtrl = TextEditingController();
  final _vaultTagCtrl = TextEditingController(text: 'Rumus & Trik');

  static const List<String> _tracks = [
    'Semua',
    'UTBK',
    'TKA',
    'SKD',
    'PSIKOTES',
    'FISIK',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newSylSubtestCtrl.dispose();
    _newSylTopicCtrl.dispose();
    _vaultTitleCtrl.dispose();
    _vaultContentCtrl.dispose();
    _vaultTagCtrl.dispose();
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
              fontSize: 13,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.checklist_rtl_rounded),
                text: 'Syllabus Mastery 3D',
              ),
              Tab(
                icon: Icon(Icons.inventory_2_rounded),
                text: 'Ammunition Vault',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSyllabusMasteryView(context),
              _buildAmmunitionVaultView(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyllabusMasteryView(BuildContext context) {
    final storage = context.watch<StorageService>();
    final items = _selectedSyllabusTrack == 'Semua'
        ? storage.syllabus
        : storage.syllabus
            .where((e) => e.track == _selectedSyllabusTrack)
            .toList();

    final greenCount = items.where((e) => e.status == 2).length;
    final yellowCount = items.where((e) => e.status == 1).length;
    final redCount = items.where((e) => e.status == 0).length;
    final masteryRatio =
        items.isEmpty ? 0.0 : (greenCount / items.length).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mastery Overview Card
          Strive3DCard(
            borderColor: StriveColors.emerald,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PROGRES PENGUASAAN SILABUS 2027',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(masteryRatio * 100).toStringAsFixed(0)}% SIAP TEMPUR',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: StriveColors.emerald,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: masteryRatio,
                    minHeight: 13,
                    backgroundColor: StriveColors.rose.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      StriveColors.emerald,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusLegendChip(
                      'Merah (Belum Kuat): $redCount',
                      StriveColors.rose,
                    ),
                    _statusLegendChip(
                      'Kuning (Proses): $yellowCount',
                      StriveColors.amber,
                    ),
                    _statusLegendChip(
                      'Hijau (Siap): $greenCount',
                      StriveColors.emerald,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tracks.map((trk) {
                final selected = _selectedSyllabusTrack == trk;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      trk,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    selected: selected,
                    selectedColor: StriveColors.emerald.withValues(alpha: 0.25),
                    onSelected: (_) =>
                        setState(() => _selectedSyllabusTrack = trk),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Add Custom Syllabus Topic
          Strive3DCard(
            child: Row(
              children: [
                SizedBox(
                  width: 78,
                  child: TextField(
                    controller: _newSylSubtestCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subtes',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _newSylTopicCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tambah Topik / Target Fisik Baru',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Strive3DButton(
                  color: StriveColors.indigo,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  onPressed: () {
                    if (_newSylTopicCtrl.text.trim().isEmpty) return;
                    storage.addSyllabusItem(
                      track: _selectedSyllabusTrack == 'Semua'
                          ? 'UTBK'
                          : _selectedSyllabusTrack,
                      subtest: _newSylSubtestCtrl.text.trim().isEmpty
                          ? 'PK'
                          : _newSylSubtestCtrl.text.trim(),
                      topic: _newSylTopicCtrl.text.trim(),
                    );
                    _newSylTopicCtrl.clear();
                  },
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Syllabus Checklist with 3-State Tactile 3D Toggle Button
          ...items.map((item) => _buildSyllabusRow(context, storage, item)),
        ],
      ),
    );
  }

  Widget _statusLegendChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSyllabusRow(
    BuildContext context,
    StorageService storage,
    SyllabusItem item,
  ) {
    Color btnColor;
    String btnLabel;
    IconData btnIcon;

    switch (item.status) {
      case 2:
        btnColor = StriveColors.emerald;
        btnLabel = 'HIJAU (Siap Tempur)';
        btnIcon = Icons.verified_rounded;
        break;
      case 1:
        btnColor = StriveColors.amber;
        btnLabel = 'KUNING (Proses)';
        btnIcon = Icons.timelapse_rounded;
        break;
      case 0:
      default:
        btnColor = StriveColors.rose;
        btnLabel = 'MERAH (Belum Paham/Kuat)';
        btnIcon = Icons.error_outline_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Strive3DCard(
        borderColor: btnColor.withValues(alpha: 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: StriveColors.indigo.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.track} • ${item.subtest}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: StriveColors.indigo,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.topic,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Strive3DButton(
              fullWidth: true,
              color: btnColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              onPressed: () => storage.cycleSyllabusStatus(item.id),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(btnIcon, size: 17),
                  const SizedBox(width: 6),
                  Text(
                    'STATUS: $btnLabel (Ketuk Ubah)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmmunitionVaultView(BuildContext context) {
    final storage = context.watch<StorageService>();
    final sortedVault = List<VaultItem>.from(storage.vault)
      ..sort((a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Strive3DCard(
            borderColor: StriveColors.amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TAMBAH AMUNISI BELAJAR & CATATAN OFFLINE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['UTBK', 'TKA', 'SKD', 'FISIK'].map((cat) {
                    return ChoiceChip(
                      label: Text(cat),
                      selected: _vaultCategory == cat,
                      onSelected: (_) => setState(() => _vaultCategory = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _vaultTitleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Judul Rumus / Link Soal / Program Fisik',
                    prefixIcon: Icon(Icons.bookmark_add_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _vaultContentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan / Rumus / URL Link Drive/Youtube',
                  ),
                ),
                const SizedBox(height: 12),
                Strive3DButton(
                  fullWidth: true,
                  color: StriveColors.amber,
                  onPressed: () async {
                    if (_vaultTitleCtrl.text.trim().isEmpty) return;
                    await storage.addVaultItem(
                      title: _vaultTitleCtrl.text.trim(),
                      category: _vaultCategory,
                      contentOrUrl: _vaultContentCtrl.text.trim(),
                      tag: _vaultTagCtrl.text.trim(),
                    );
                    _vaultTitleCtrl.clear();
                    _vaultContentCtrl.clear();
                  },
                  child: const Text('SIMPAN KE AMMUNITION VAULT'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'BRANKAS AMUNISI TERSIMPAN (100% OFFLINE)',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 10),
          if (sortedVault.isEmpty)
            const IgnisMascotWidget(
              mood: IgnisMood.happyHype,
              speechText:
                  'Brankas Amunisi masih kosong! Simpan rumus cepat PK, trik TIU, atau link paket soal di sini!',
              size: 80,
            )
          else
            ...sortedVault.map((v) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Strive3DCard(
                  borderColor: v.isPinned ? StriveColors.amber : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  StriveColors.emerald.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              v.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: StriveColors.emerald,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              v.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => storage.togglePinVaultItem(v.id),
                            icon: Icon(
                              v.isPinned
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                              color: v.isPinned
                                  ? StriveColors.amber
                                  : StriveColors.textSecondary(context),
                              size: 20,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: '${v.title}\n${v.contentOrUrl}',
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('📋 Disalin ke papan klip!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 19),
                          ),
                          IconButton(
                            onPressed: () => storage.deleteVaultItem(v.id),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: StriveColors.rose,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        v.contentOrUrl,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: StriveColors.textPrimary(context),
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
