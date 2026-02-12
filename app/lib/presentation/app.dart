import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'pages/calendar/calendar_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'shukare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const CalendarScreen(),
    );
  }
}
