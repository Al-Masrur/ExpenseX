import 'package:flutter/material.dart';

import 'package:expensex/features/home/home_shell.dart';

class AppRouter {
  static const dashboard = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const HomeShell());
  }
}
