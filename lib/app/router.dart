import 'package:flutter/material.dart';

import 'package:expensex/features/dashboard/dashboard_page.dart';

class AppRouter {
  static const dashboard = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
      default:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
    }
  }
}
