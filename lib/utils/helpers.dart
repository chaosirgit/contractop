import 'dart:convert';

import 'package:contractop/utils/constants.dart';
import 'package:encrypt/encrypt.dart';
class myResponse {
  final int code;
  final String message;
  final Object? data;

  myResponse(this.code,this.message,{this.data});

  static myResponse success({String message = "",Object? data}){
    return myResponse(200,message,data: data);
  }

  static myResponse error({String message = "",Object? data}) {
    return myResponse(400,message,data: data);
  }

  Map<String, Object?> toMap() {
    var map = {
      "code" : code,
      "message": message,
      "data" : data
    };
    return map;
  }
}

String encrypt(String text){
  var key = Key.fromUtf8("qW7BPsLLXfLWHfjgNjBaib7YKcSd7M+d");
  final iv = IV.fromLength(16);
  var encrypter = Encrypter(AES(key,padding: null));
  return encrypter.encrypt(text, iv: iv).base64;
}

String decrypt(String text){
  var key = Key.fromUtf8("qW7BPsLLXfLWHfjgNjBaib7YKcSd7M+d");
  final iv = IV.fromLength(16);
  var encrypter = Encrypter(AES(key,padding: null));
  var encrypted = encrypter.decryptBytes(Encrypted.fromBase64(text),iv:iv);
  return utf8.decode(encrypted);
}
/// 根据 ABI 解析出方法
Map parseAbi(String abi){
  var abiObj = jsonDecode(abi);
  var send = abiObj.where((o) {
    if (o['type'] == "function" && o['stateMutability'] != "view"){
      return true;
    }
    return false;
  }).toList();
  var read = abiObj.where((e) => e['type'] == "function" && e['stateMutability'] == "view").toList();

  return {"send":send,"read":read};
}