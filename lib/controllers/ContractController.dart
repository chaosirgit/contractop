import 'dart:convert';

import 'package:contractop/models/Contract.dart';
import 'package:contractop/models/Operator.dart';
import 'package:contractop/service/StorageService.dart';
import 'package:contractop/utils/helpers.dart';
import 'package:get/get.dart';

class ContractController extends GetxController {
  final title = "".obs;
  final storage = Get.find<StorageService>();
  var contracts = [].obs;
  final abi = "".obs;
  final name = "".obs;
  final publicKey = "".obs;
  final chainId = "".obs;

  void getTitle() async {
    var opId = await storage.box.read("operatorId");
    var op = await Operator.find(opId);
    title.value = "Hi ${op['name']}";
  }

  Future<myResponse> addContract() async {
    if (name.value == "") {
      return myResponse.error(message: "Please set contract name");
    }
    if (publicKey.value == "") {
      return myResponse.error(message: "Please set contract address");
    }
    if (abi.value == "") {
      return myResponse.error(message: "Please set contract abi");
    }
    if (chainId.value == "") {
      return myResponse.error(message: "Please set ChainID");
    }
    try {
      var cid = int.parse(chainId.value);
      if (cid != 56 && cid != 97 && cid != 1){
        return myResponse.error(message: "ChainID Error");
      }
      var abiObj = jsonDecode(abi.value);
      var ct = await Contract.first(
          where: "public_key = ?", whereArgs: [publicKey.value]);
      if (ct != null) {
        return myResponse.error(message: "This contract has been exists");
      } else {
        var data = {
          "public_key": publicKey.value,
          "abi": jsonEncode(abiObj),
          "name": name.value,
          "chain_id": cid,
        };
        await Contract.fromMap(data).save();
      }
      return myResponse.success();
    } on FormatException catch (e) {
      print(e);
      return myResponse.error(message: "Format error");
    } catch (e) {
      print(e);
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
}
