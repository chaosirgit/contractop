import 'package:contractop/models/Model.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Rpc extends Model {
  @override
  final int id;
  final String name;
  final String uri;
  static String tableName = 'rpc';

  Rpc({required this.id,required this.name,required this.uri});

  @override
  Map<String,Object?> toMap(){
    Map<String,Object?> map = {
      "id" : id,
      "name" : name,
      "uri" : uri,
    };
    if (id != null && id as int > 0){
      map["id"] = id;
    }
    return map;
  }

  Future<Rpc> create() async {
    id = await Model.dbService.db.insert(tableName, toMap());
    return this;
  }

  Future<Rpc> save() async {
    if (id == null || id as int <= 0){
      id = await Model.dbService.db.insert(tableName, toMap());
    }else{
      if (await exists()){
        await Model.dbService.db.update(tableName, toMap(),where: 'id = ?',whereArgs: [id]);
      }
    }
    return this;
  }

  Future<int> delete() async {
    if (id != null && id as int > 0){
      if (await exists()){
        return await Model.dbService.db.delete(tableName, where: 'id = ?',whereArgs: [id]);
      }
    }
    return 0;
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

  static Future<List<Map>> get({String? where, List<Object?>? whereArgs,int? limit,int? offset,String? orderBy}) async {
    var results = <Map>[];
    List<Map> rows = await Model.dbService.db.query(tableName,where:where,whereArgs: whereArgs,limit: limit,offset: offset,orderBy: orderBy);
    if(rows.isNotEmpty){
      return rows;
    }
    return results;
  }

  static Future<Map?> first({String? where, List<Object?>? whereArgs}) async {
    List<Map> rows = await get(where: where,whereArgs: whereArgs,limit: 1,orderBy: 'id desc');
    if(rows.isNotEmpty){
      return rows.first;
    }
    return null;
  }

  static Rpc fromMap(Map first) {
    return Rpc(id: first["id"],name: first["name"],uri: first["uri"]);
  }




}