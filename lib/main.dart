import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/analytics_tab_screen.dart';
import 'screens/journey_tab_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_shop_tab_screen.dart';
import 'screens/syllabus_vault_tab_screen.dart';
import 'screens/tryout_samapta_tab_screen.dart';
import 'screens/workout_timer_sheet.dart';
import 'services/storage_service.dart';
import 'widgets/strive_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();

  runApp(
    ChangeNotifierProvider<StorageService>.value(
      value: storage,
      child: const StriveApp(),
    ),
  );
}

class StriveApp extends StatelessWidget {
  const StriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return MaterialApp(
      title: 'Strive - Road to UTBK, TKA & Sekolah Kedinasan 2027',
      debugShowCheckedModeBanner: false,
      theme: StriveTheme.lightTheme(),
      darkTheme: StriveTheme.darkTheme(),
      themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: storage.profile == null
          ? const OnboardingScreen()
          : const StriveMainShell(),
    );
  }
}

class StriveMainShell extends StatefulWidget {
  const StriveMainShell({super.key});

  @override
  State<StriveMainShell> createState() => _StriveMainShellState();
}

class _StriveMainShellState extends State<StriveMainShell> {
  int _currentTab = 0;

  void _openWorkoutSheet({int initialTab = 0}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkoutTimerSheet(initialTabIndex: initialTab),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      JourneyTabScreen(
        onOpenTimer: () => _openWorkoutSheet(initialTab: 0),
        onSwitchTab: (idx) => setState(() => _currentTab = idx),
      ),
      const AnalyticsTabScreen(),
      const TryoutSamaptaTabScreen(),
      const SyllabusVaultTabScreen(),
      const ProfileShopTabScreen(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDark ? StriveColors.darkSurface : StriveColors.lightSurface,
            border: Border(
              bottom: BorderSide(
                color: StriveColors.border(context),
                width: 2,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // Track Filter Pill ('Semua', 'UTBK & TKA', 'Kedinasan')
                  PopupMenuButton<String>(
                    initialValue: storage.activeTrackFilter,
                    onSelected: (val) => storage.setTrackFilter(val),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'Semua',
                        child: Text('🎯 Semua Track (Hybrid)'),
                      ),
                      PopupMenuItem(
                        value: 'UTBK & TKA',
                        child: Text('🎓 UTBK-SNBT & TKA'),
                      ),
                      PopupMenuItem(
                        value: 'Kedinasan',
                        child: Text('🛡️ Sekolah Kedinasan'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: StriveColors.emerald.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: StriveColors.emerald.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 15,
                            color: StriveColors.emerald,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            storage.activeTrackFilter,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: StriveColors.emerald,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 16,
                            color: StriveColors.emerald,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Streak Flame Count
                  _hudPill(
                    icon: Icons.local_fire_department_rounded,
                    label: '${storage.streakCount}',
                    color: StriveColors.amber,
                    onTap: () => _openWorkoutSheet(initialTab: 0),
                  ),
                  const SizedBox(width: 6),

                  // Coin Balance
                  _hudPill(
                    icon: Icons.monetization_on_rounded,
                    label: '${storage.coins}',
                    color: const Color(0xFFEAB308),
                    onTap: () => setState(() => _currentTab = 4),
                  ),
                  const SizedBox(width: 6),

                  // EXP Level Badge
                  _hudPill(
                    icon: Icons.bolt_rounded,
                    label: 'LV.${storage.level}',
                    color: StriveColors.indigo,
                    onTap: () => setState(() => _currentTab = 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentTab,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: StriveColors.emerald,
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: () => _openWorkoutSheet(
          initialTab: _currentTab == 2 ? 1 : 0,
        ),
        icon: const Icon(Icons.timer_rounded),
        label: const Text(
          'Mulai Latihan Hari Ini',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: StriveColors.border(context),
              width: 2,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentTab,
          height: 68,
          backgroundColor:
              isDark ? StriveColors.darkSurface : StriveColors.lightSurface,
          indicatorColor: StriveColors.emerald.withValues(alpha: 0.22),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (idx) {
            HapticFeedback.selectionClick();
            setState(() => _currentTab = idx);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon:
                  Icon(Icons.route_rounded, color: StriveColors.emerald),
              label: 'Journey',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon:
                  Icon(Icons.insights_rounded, color: StriveColors.emerald),
              label: 'Cartesian',
            ),
            NavigationDestination(
              icon: Icon(Icons.military_tech_outlined),
              selectedIcon: Icon(
                Icons.military_tech_rounded,
                color: StriveColors.emerald,
              ),
              label: 'TO & Fisik',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_rtl_outlined),
              selectedIcon: Icon(
                Icons.checklist_rtl_rounded,
                color: StriveColors.emerald,
              ),
              label: 'Silabus',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon:
                  Icon(Icons.storefront_rounded, color: StriveColors.emerald),
              label: 'Shop & Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _hudPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
