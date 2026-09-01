import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../domain/entity/mbti.dart';
import '../../../domain/entity/persona_type.dart';
import '../../providers/calendar_week_start_provider.dart';
import '../../providers/checked_dates_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/target_wake_up_time_provider.dart';
import '../../providers/user_profile_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.settings,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _sectionTitle(context, l10n.sectionGoal),
          const _TargetWakeUpTimeTile(),
          const SizedBox(height: 24),
          _sectionTitle(context, l10n.sectionPersonalize),
          const _PersonaTypeTile(),
          const _MbtiTile(),
          const SizedBox(height: 24),
          _sectionTitle(context, l10n.sectionNotification),
          const _NotificationSwitch(),
          const _NotificationTimeTile(),
          const SizedBox(height: 24),
          _sectionTitle(context, l10n.sectionCalendar),
          const _CalendarWeekStartTile(),
          const SizedBox(height: 24),
          _sectionTitle(context, l10n.sectionData),
          const _ResetDataTile(),
        ],
      ),
    );
  }

  static Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _TargetWakeUpTimeTile extends ConsumerWidget {
  const _TargetWakeUpTimeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final targetTimeAsync = ref.watch(targetWakeUpTimeProvider);
    return targetTimeAsync.when(
      data: (targetTime) => _SettingsCard(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.alarm_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          title: Text(
            l10n.targetWakeUpTime,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(
            l10n.targetWakeUpTimeSubtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              targetTime.toDisplayString(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          onTap: () => _pickTime(context, ref, targetTime.hour, targetTime.minute),
        ),
      ),
      loading: () => _SettingsCard(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.alarm_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          title: Text(
            l10n.targetWakeUpTime,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          trailing: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => _SettingsCard(
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: Text(l10n.loadError),
        ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    int initialHour,
    int initialMinute,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      helpText: l10n.wakeUpTimeHelpText,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  surface: AppColors.surface,
                ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (time != null && context.mounted) {
      await ref.read(targetWakeUpTimeProvider.notifier).setTargetWakeUpTime(
            time.hour,
            time.minute,
          );
      if (context.mounted) {
        final timeStr =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.wakeUpTimeSet(timeStr)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}

class _PersonaTypeTile extends ConsumerWidget {
  const _PersonaTypeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);
    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appPersonality,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.appPersonalitySubtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PersonaChip(
                    label: l10n.personaGentle,
                    description: l10n.personaGentleDesc,
                    selected: profile.personaType == PersonaType.gentle,
                    onTap: () => ref
                        .read(userProfileProvider.notifier)
                        .setPersonaType(PersonaType.gentle),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PersonaChip(
                    label: l10n.personaStrict,
                    description: l10n.personaStrictDesc,
                    selected: profile.personaType == PersonaType.strict,
                    onTap: () => ref
                        .read(userProfileProvider.notifier)
                        .setPersonaType(PersonaType.strict),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonaChip extends StatelessWidget {
  const _PersonaChip({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MbtiTile extends ConsumerWidget {
  const _MbtiTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);
    return _SettingsCard(
      child: ListTile(
        title: Text(
          l10n.mbtiType,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: Text(
          profile.mbti != null
              ? '${profile.mbti!.code} - ${profile.mbti!.localizedName(Localizations.localeOf(context).languageCode)}'
              : l10n.mbtiNotSet,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: () => _showMbtiSelector(context, ref, profile.mbti),
      ),
    );
  }

  Future<void> _showMbtiSelector(
    BuildContext context,
    WidgetRef ref,
    MBTI? currentMbti,
  ) async {
    final selected = await showModalBottomSheet<MBTI?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MbtiSelectorSheet(currentMbti: currentMbti),
    );

    if (selected != null || selected != currentMbti) {
      await ref.read(userProfileProvider.notifier).setMbti(selected);
    }
  }
}

class _MbtiSelectorSheet extends StatelessWidget {
  const _MbtiSelectorSheet({this.currentMbti});

  final MBTI? currentMbti;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectMbtiTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.mbtiSelectSubtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSection(context, l10n.mbtiGroupAnalyst, [
                  MBTI.intj,
                  MBTI.intp,
                  MBTI.entj,
                  MBTI.entp,
                ]),
                _buildSection(context, l10n.mbtiGroupDiplomat, [
                  MBTI.infj,
                  MBTI.infp,
                  MBTI.enfj,
                  MBTI.enfp,
                ]),
                _buildSection(context, l10n.mbtiGroupSentinel, [
                  MBTI.istj,
                  MBTI.isfj,
                  MBTI.estj,
                  MBTI.esfj,
                ]),
                _buildSection(context, l10n.mbtiGroupExplorer, [
                  MBTI.istp,
                  MBTI.isfp,
                  MBTI.estp,
                  MBTI.esfp,
                ]),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    l10n.mbtiSkip,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<MBTI> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...types.map((mbti) => _MbtiOptionTile(
              mbti: mbti,
              isSelected: mbti == currentMbti,
              onTap: () => Navigator.of(context).pop(mbti),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _MbtiOptionTile extends StatelessWidget {
  const _MbtiOptionTile({
    required this.mbti,
    required this.isSelected,
    required this.onTap,
  });

  final MBTI mbti;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.15)
          : AppColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  mbti.code,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mbti.localizedName(Localizations.localeOf(context).languageCode),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      mbti.localizedDescription(Localizations.localeOf(context).languageCode),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSwitch extends ConsumerWidget {
  const _NotificationSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationAsync = ref.watch(notificationProvider);
    return notificationAsync.when(
      data: (settings) => _SettingsCard(
        child: SwitchListTile(
          value: settings.enabled,
          onChanged: (value) =>
              ref.read(notificationProvider.notifier).setEnabled(value),
          title: Text(
            l10n.notificationEnable,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          activeThumbColor: AppColors.primary,
        ),
      ),
      loading: () => _SettingsCard(
        child: ListTile(
          title: Text(
            l10n.notificationEnable,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          trailing: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => _SettingsCard(
        child: ListTile(title: Text(l10n.loadError)),
      ),
    );
  }
}

class _NotificationTimeTile extends ConsumerWidget {
  const _NotificationTimeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationAsync = ref.watch(notificationProvider);
    return notificationAsync.when(
      data: (settings) => _SettingsCard(
        child: ListTile(
          title: Text(
            l10n.notificationTime,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(
            '${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          onTap: () => _pickTime(context, ref, settings.hour, settings.minute),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    int initialHour,
    int initialMinute,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (time != null && context.mounted) {
      await ref.read(notificationProvider.notifier).setTime(time.hour, time.minute);
    }
  }
}

class _CalendarWeekStartTile extends ConsumerWidget {
  const _CalendarWeekStartTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final weekStartSunday = ref.watch(calendarWeekStartSundayProvider);
    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weekStart,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _WeekStartChip(
                    label: l10n.sunday,
                    selected: weekStartSunday,
                    onTap: () => ref
                        .read(calendarWeekStartSundayProvider.notifier)
                        .setWeekStartSunday(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WeekStartChip(
                    label: l10n.monday,
                    selected: !weekStartSunday,
                    onTap: () => ref
                        .read(calendarWeekStartSundayProvider.notifier)
                        .setWeekStartSunday(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStartChip extends StatelessWidget {
  const _WeekStartChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetDataTile extends ConsumerWidget {
  const _ResetDataTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return _SettingsCard(
      child: ListTile(
        title: Text(
          l10n.resetAllData,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: const Icon(
          Icons.delete_outline,
          color: AppColors.textSecondary,
          size: 22,
        ),
        onTap: () => _showResetConfirmDialog(context, ref),
      ),
    );
  }

  Future<void> _showResetConfirmDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dl = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dl.resetDataTitle),
          content: Text(dl.resetDataContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(dl.cancel, style: const TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(dl.reset, style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      await ref.read(checkedDatesProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.resetDone)),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
