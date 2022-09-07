import 'package:contractop/models/Model.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Wallet extends Model {
  @override
  final int? id;
  final String? publicKey;
  final String? secretKey;
  static String tableName = 'wallet';

  Wallet({this.id,this.publicKey,this.secretKey});

  @override
  Map<String,Object?> toMap(){
    Map<String,Object?> map = {
      "public_key" : publicKey,
      "secret_key" : secretKey
    };
    if (id != null && id as int > 0){
      map["id"] = id;
    }
    return map;
  }

  Future<Wallet> save() async {
    if (id == null || id as int <= 0){
      id = await Model.dbService.db.insert(tableName, toMap());
    }else{
      if (await exists()){
        await Model.dbService.db.update(tableName, toMap(),where: 'id = ?',whereArgs: [id]);
      }
    }
    return this;
  }

  Future<bool> exists() async {
    if (id != null && id as int > 0){
      var data = await find(id as int);
      var w = fromMap(data);
      if (w.id != null && w.id as int > 0){
        return true;
      }
    }
    return false;
  }



  static Future<Map<String,Object?>> find(int id) async {
    List<Map<String,Object?>> results = await Model.dbService.db.query(tableName,where: 'id = ?',whereArgs: [id]);
    return results.first;
  }

  static Future<List<Map>> all() async {
    var results = <Map>[];
    List<Map> rows = await Model.dbService.db.query(tableName);
    if(rows.isNotEmpty){
      return rows;
    }
    return results;
  }

  static Future<List<Map>> get({String? where, List<Object?>? whereArgs,int? limit,int? offset}) async {
    var results = <Map>[];
    List<Map> rows = await Model.dbService.db.query(tableName,where:where,whereArgs: whereArgs,limit: limit,offset: offset);
    if(rows.isNotEmpty){
      return rows;
    }
    return results;
  }

  static Wallet fromMap(Map first) {
    return Wallet(id: first["id"],publicKey: first["public_key"],secretKey: first["secret_key"]);
  }




}