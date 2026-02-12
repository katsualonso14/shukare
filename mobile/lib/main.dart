import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'infrastructure/datasource/notification_schedule_datasource.dart';
import 'infrastructure/di/infrastructure_providers.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');
  final prefs = await SharedPreferences.getInstance();

  final scheduleDatasource = NotificationScheduleDatasource();
  await scheduleDatasource.initialize();
  final enabled = prefs.getBool('notification_enabled') ?? true;
  if (enabled) {
    final hour = prefs.getInt('notification_hour') ?? 20;
    final minute = prefs.getInt('notification_minute') ?? 0;
    await scheduleDatasource.scheduleDaily(hour: hour, minute: minute);
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
}
