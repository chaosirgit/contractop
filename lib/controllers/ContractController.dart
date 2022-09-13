import 'dart:convert';

import 'package:contractop/models/Contract.dart';
import 'package:contractop/models/Operator.dart';
import 'package:contractop/service/StorageService.dart';
import 'package:contractop/utils/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ContractController extends GetxController {
  final title = "".obs;
  final storage = Get.find<StorageService>();
  var contracts = [].obs;
  final abiTextEditController = TextEditingController().obs;
  final nameTextEditController = TextEditingController().obs;
  final publicKeyTextEditController = TextEditingController().obs;
  final chainIdTextEditController = TextEditingController().obs;
  final id = 0.obs;

  void getTitle() async {
    var opId = await storage.box.read("operatorId");
    var op = await Operator.find(opId);
    title.value = "Hi ${op['name']}";
  }

  Future<myResponse> addContract() async {
    if (nameTextEditController.value.text == "") {
      return myResponse.error(message: "Please set contract name");
    }
    if (publicKeyTextEditController.value.text == "") {
      return myResponse.error(message: "Please set contract address");
    }
    if (abiTextEditController.value.text == "") {
      return myResponse.error(message: "Please set contract abi");
    }
    if (chainIdTextEditController.value.text == "") {
      return myResponse.error(message: "Please set ChainID");
    }
    try {
      var cid = int.parse(chainIdTextEditController.value.text);
      if (cid != 56 && cid != 97 && cid != 1){
        return myResponse.error(message: "ChainID Error");
      }
      var abiObj = jsonDecode(abiTextEditController.value.text);
      var ct = await Contract.first(
          where: "public_key = ?", whereArgs: [publicKeyTextEditController.value.text]);
      if (ct != null) {
        return myResponse.error(message: "This contract has been exists");
      } else {
        var data = {
          "public_key": publicKeyTextEditController.value.text,
          "abi": jsonEncode(abiObj),
          "name": nameTextEditController.value.text,
          "chain_id": cid,
        };
        await Contract.fromMap(data).save();
      }
      abiTextEditController.value.text = "";
      chainIdTextEditController.value.text = "";
      publicKeyTextEditController.value.text = "";
      nameTextEditController.value.text = "";
      id.value = 0;
      return myResponse.success();
    } on FormatException catch (e) {
      return myResponse.error(message: "Format error");
    } catch (e) {
      return myResponse.error(message: e.toString());
    }
  }

  Future<void> getContracts() async {
    var any = await Contract.all();
    contracts.value = any;
    update();
  }

  Future<myResponse> deleteContract(Map map) async {
    var c = Contract.fromMap(map);
    var count = await c.delete();
    if (count > 0){
      return myResponse.success();
    }
    return myResponse.error(message: "Delete fair,Please try again");
  }

  Future<myResponse> selectContract(Map map) async {
    final storage = Get.find<StorageService>();
    await storage.box.write("contractId", map["id"]);
    return myResponse.success();
  }

  Future<myResponse> editContract() async {
    if (nameTextEditController.value.text == "") {
      return myResponse.error(message: "Please set contract name");
    }
    if (publicKeyTextEditController.value.text == "") {
      return myResponse.error(message: "Please set contract address");
    }
    if (abiTextEditController.value.text == "") {
      return myResponse.error(message: "Please set contract abi");
    }
    if (chainIdTextEditController.value.text == "") {
      return myResponse.error(message: "Please set ChainID");
    }
    try {
      if (id <= 0){
        return myResponse.error(message: "This contract not found");
      }
      var cid = int.parse(chainIdTextEditController.value.text);
      if (cid != 56 && cid != 97 && cid != 1){
        return myResponse.error(message: "ChainID Error");
      }
      var abiObj = jsonDecode(abiTextEditController.value.text);
      var ct = await Contract.first(
          where: "id = ?", whereArgs: [id.value]);
      if (ct == null) {
        return myResponse.error(message: "This contract not found");
      } else {
        var data = {
          "public_key": publicKeyTextEditController.value.text,
          "abi": jsonEncode(abiObj),
          "name": nameTextEditController.value.text,
          "chain_id": cid,
          "id" : id.value,
        };
        await Contract.fromMap(data).save();
      }
      abiTextEditController.value.text = "";
      chainIdTextEditController.value.text = "";
      publicKeyTextEditController.value.text = "";
      nameTextEditController.value.text = "";
      id.value = 0;
      return myResponse.success();
    } on FormatException catch (e) {
      return myResponse.error(message: "Format error");
    } catch (e) {
      return myResponse.error(message: e.toString());
    }
  }
}
