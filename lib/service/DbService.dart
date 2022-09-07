import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

class DbService extends GetxService {
  late final Database db;

  Future<DbService> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    db = await openDatabase(
      join(await getDatabasesPath(), 'contractop.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE wallet(id INTEGER PRIMARY KEY AUTOINCREMENT, public_key TEXT, secret_key TEXT)',
        );
      },
      version: 1,
    );
    return this;
  }
}
