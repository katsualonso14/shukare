import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../infrastructure/di/infrastructure_providers.dart';
import '../calendar/calendar_screen.dart';
import '../weekly_stats/weekly_stats_screen.dart';

const _screenNames = ['calendar', 'weekly_stats'];

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          CalendarScreen(),
          WeeklyStatsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          ref.read(analyticsServiceProvider).logScreenView(_screenNames[i]);
          setState(() => _currentIndex = i);
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insert_chart_outlined_rounded),
            selectedIcon: const Icon(Icons.insert_chart_rounded),
            label: l10n.navStats,
          ),
        ],
      ),
    );
  }
}
