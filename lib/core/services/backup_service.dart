import 'dart:io';

import 'package:expensex/data/database/app_database.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupService {
  const BackupService();

  Future<Directory> getBackupDirectory() async {
    final documents = await getApplicationDocumentsDirectory();

    final backupDir = Directory(p.join(documents.path, 'expensex', 'backups'));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  Future<File> createBackup() async {
    final backupDirectory = await getBackupDirectory();

    final database = AppDatabase.instance;

    final databaseFile = await database.databaseFile;

    final now = DateTime.now();

    final fileName =
        'expensex_backup_'
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}.db';

    final destination = File(p.join(backupDirectory.path, fileName));

    await database.closeDatabase();

    try {
      await databaseFile.copy(destination.path);
    } finally {
      await database.reopenDatabase();
    }

    return destination;
  }
}
