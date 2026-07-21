import 'package:flutter/material.dart';

import 'package:expensex/app/app.dart';
import 'package:expensex/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  runApp(const ExpenseXApp());
}
