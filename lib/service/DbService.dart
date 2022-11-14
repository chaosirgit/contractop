import 'dart:io';

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
        db.execute(
          'CREATE TABLE operator(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, public_key TEXT, secret_key TEXT)',
        );
        db.execute(
          'CREATE TABLE contract(id INTEGER PRIMARY KEY AUTOINCREMENT,chain_id INTEGER, name TEXT, public_key TEXT, abi TEXT)',
        );
        return;
      },
      onUpgrade: (db, oldVersion, newVersion) {
        print("数据库需要升级！旧版：$oldVersion,新版：$newVersion");
        db.execute(
            'CREATE TABLE rpc(id INTEGER PRIMARY KEY, name TEXT, uri TEXT)'
        );
        return;
      },
      version: 2,
    );
    return this;
  }
}
