import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/calendar_week_start_provider.dart';
import '../../providers/checked_dates_provider.dart';
import '../../providers/notification_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          '設定',
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
          _sectionTitle(context, '通知'),
          const _NotificationSwitch(),
          const _NotificationTimeTile(),
          const SizedBox(height: 24),
          _sectionTitle(context, 'カレンダー'),
          const _CalendarWeekStartTile(),
          const SizedBox(height: 24),
          _sectionTitle(context, 'データ'),
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

class _NotificationSwitch extends ConsumerWidget {
  const _NotificationSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationAsync = ref.watch(notificationProvider);
    return notificationAsync.when(
      data: (settings) => _SettingsCard(
        child: SwitchListTile(
          value: settings.enabled,
          onChanged: (value) =>
              ref.read(notificationProvider.notifier).setEnabled(value),
          title: const Text(
            '通知をする',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          activeColor: AppColors.primary,
        ),
      ),
      loading: () => const _SettingsCard(
        child: ListTile(
          title: Text('通知をする', style: TextStyle(color: AppColors.textSecondary)),
          trailing: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const _SettingsCard(
        child: ListTile(title: Text('読み込みに失敗しました')),
      ),
    );
  }
}

class _NotificationTimeTile extends ConsumerWidget {
  const _NotificationTimeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationAsync = ref.watch(notificationProvider);
    return notificationAsync.when(
      data: (settings) => _SettingsCard(
        child: ListTile(
          title: const Text(
            '通知時刻',
            style: TextStyle(
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
    final weekStartSunday = ref.watch(calendarWeekStartSundayProvider);
    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '週の始まり',
              style: TextStyle(
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
                    label: '日曜日',
                    selected: weekStartSunday,
                    onTap: () => ref
                        .read(calendarWeekStartSundayProvider.notifier)
                        .setWeekStartSunday(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WeekStartChip(
                    label: '月曜日',
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
      color: selected ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
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
    return _SettingsCard(
      child: ListTile(
        title: const Text(
          'データをすべてリセット',
          style: TextStyle(
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データのリセット'),
        content: const Text(
          'チェックした日付データをすべて削除します。\nこの操作は取り消せません。よろしいですか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('キャンセル', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('リセット', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(checkedDatesProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('データをリセットしました')),
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
