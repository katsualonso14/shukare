import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entity/wake_up_status.dart';
import '../../../../infrastructure/di/infrastructure_providers.dart';
import '../../../providers/wake_up_records_provider.dart';

/// 日付をタップしたときに表示するボトムシート（記録編集専用）
/// 当日以前の日付のみ表示される（未来日は month_calendar 側で弾く）
Future<void> showDateDetailBottomSheet({
  required BuildContext context,
  required DateTime date,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _DateDetailSheet(date: date),
    ),
  );
}

class _DateDetailSheet extends ConsumerWidget {
  const _DateDetailSheet({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final wakeUpRecordsAsync = ref.watch(wakeUpRecordsProvider);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dateFormat = locale == 'ja' ? 'M月d日（E）' : 'EEE, MMM d';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            DateFormat(dateFormat, locale).format(date),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          wakeUpRecordsAsync.when(
            data: (records) => _OptionList(
              date: date,
              currentStatus: records[dateKey]?.status,
              l10n: l10n,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('$e', style: const TextStyle(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionList extends ConsumerWidget {
  const _OptionList({
    required this.date,
    required this.currentStatus,
    required this.l10n,
  });

  final DateTime date;
  final WakeUpStatus? currentStatus;
  final AppLocalizations l10n;

  Future<void> _onTap(WidgetRef ref, WakeUpStatus tapped, BuildContext context) async {
    final analytics = ref.read(analyticsServiceProvider);
    if (currentStatus == tapped) {
      await ref.read(wakeUpRecordsProvider.notifier).deleteRecord(date);
      await analytics.logWakeUpDeleted();
    } else {
      await ref.read(wakeUpRecordsProvider.notifier).recordWithStatus(
            date: date,
            status: tapped,
          );
      await analytics.logWakeUpRecorded(tapped.name);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _OptionTile(
          leading: _GreenDot(),
          label: l10n.optionSuccess,
          deleteHint: l10n.tapAgainToDelete,
          isSelected: currentStatus == WakeUpStatus.success,
          selectedColor: AppColors.primary,
          onTap: () => _onTap(ref, WakeUpStatus.success, context),
        ),
        const SizedBox(height: 10),
        _OptionTile(
          leading: const Text('🌙', style: TextStyle(fontSize: 20)),
          label: l10n.optionRested,
          deleteHint: l10n.tapAgainToDelete,
          isSelected: currentStatus == WakeUpStatus.rested,
          selectedColor: const Color(0xFF9BB5C4),
          onTap: () => _onTap(ref, WakeUpStatus.rested, context),
        ),
        const SizedBox(height: 10),
        _OptionTile(
          leading: const Text('☁️', style: TextStyle(fontSize: 20)),
          label: l10n.optionAdjusted,
          deleteHint: l10n.tapAgainToDelete,
          isSelected: currentStatus == WakeUpStatus.adjusted,
          selectedColor: AppColors.warmGray,
          onTap: () => _onTap(ref, WakeUpStatus.adjusted, context),
        ),
      ],
    );
  }
}

class _GreenDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.dayCheckedCircle,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.dayCheckedCircleInner,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.leading,
    required this.label,
    required this.deleteHint,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final Widget leading;
  final String label;
  final String deleteHint;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.5)
                : AppColors.textMuted.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? selectedColor : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      deleteHint,
                      style: TextStyle(
                        color: selectedColor.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_rounded, color: selectedColor, size: 20),
          ],
        ),
      ),
    );
  }
}
