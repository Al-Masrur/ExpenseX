import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensex/core/theme/theme_provider.dart';
import 'package:expensex/app/router.dart';
import 'package:expensex/core/theme/app_theme.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/features/income/providers/income_provider.dart';
import 'package:expensex/features/budget/providers/budget_provider.dart';

class ExpenseXApp extends StatelessWidget {
  const ExpenseXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),

        ChangeNotifierProvider(
          create: (_) => ExpenseProvider()..loadExpenses(),
        ),

        ChangeNotifierProvider(create: (_) => IncomeProvider()..loadIncomes()),

        ChangeNotifierProvider(create: (_) => BudgetProvider()..loadBudgets()),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ExpenseX',
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            themeMode: themeProvider.themeMode,

            initialRoute: AppRouter.dashboard,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
