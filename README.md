# Spendigo

A modern personal finance, income, and expense tracking application built with Flutter & Dart.

## Features

- **Dashboard**: Real-time balance summary, recent transactions, and quick action shortcuts.
- **Expense & Income Tracking**: Record, categorize, view, and manage daily transactions.
- **Budgeting**: Set monthly spending caps with threshold warnings and notifications.
- **Analytics & Visualizations**: Category breakdowns with interactive pie charts and monthly financial trends.
- **Data Backup & Export**: Export transaction history to CSV format and backup/restore local SQLite database.
- **Theming & Multi-Currency**: Support for Light, Dark, and System theme modes, along with multiple currencies (BDT, USD, EUR).

## Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [sqflite](https://pub.dev/packages/sqflite) (SQLite) & [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **File & Share**: [csv](https://pub.dev/packages/csv), [share_plus](https://pub.dev/packages/share_plus), [path_provider](https://pub.dev/packages/path_provider)

## Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Analyze & Test**:
   ```bash
   flutter analyze
   flutter test
   ```
