import 'package:flutter/material.dart';

import 'package:expensex/app/router.dart';
import 'package:expensex/core/theme/app_theme.dart';

class ExpenseXApp extends StatelessWidget {
  const ExpenseXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpenseX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.dashboard,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
