import 'dart:io';

import 'package:expensex/data/database/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> restoreBackup(File backupFile) async {
    final database = AppDatabase.instance;
    final databaseFile = await database.databaseFile;

    await database.closeDatabase();

    try {
      await backupFile.copy(databaseFile.path);
    } finally {
      await database.reopenDatabase();
    }
  }

  Future<List<File>> getBackups() async {
    final backupDirectory = await getBackupDirectory();
    final entities = backupDirectory.listSync();
    final files = entities.whereType<File>().where((f) => f.path.endsWith('.db')).toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  Future<void> shareBackup(File file) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'ExpenseX Database Backup'),
    );
  }
}
