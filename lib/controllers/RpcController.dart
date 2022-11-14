import 'dart:convert';

import 'package:contractop/models/Contract.dart';
import 'package:contractop/models/Operator.dart';
import 'package:contractop/models/Rpc.dart';
import 'package:contractop/service/StorageService.dart';
import 'package:contractop/utils/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RpcController extends GetxController {
    final title = "RPC Setting";
    final storage = Get.find<StorageService>();
    var rpc = [].obs;
    final nameTextEditController = TextEditingController().obs;
    final uriTextEditController = TextEditingController().obs;
    final chainIdTextEditController = TextEditingController().obs;
    final id = 0.obs;

    Future<myResponse> addRpc() async {
        if (nameTextEditController.value.text == "") {
            return myResponse.error(message: "Please set chain name");
        }
        if (uriTextEditController.value.text == "") {
            return myResponse.error(message: "Please set rpc");
        }
        if (chainIdTextEditController.value.text == "") {
            return myResponse.error(message: "Please set ChainID");
        }
        try {
            var cid = int.parse(chainIdTextEditController.value.text);
            var ct = await Rpc.first(
                where: "id = ?", whereArgs: [cid]);
            if (ct != null) {
                return myResponse.error(message: "This chainID has been exists");
            } else {
                var data = {
                    "uri": uriTextEditController.value.text,
                    "name": nameTextEditController.value.text,
                    "id": cid,
                };
                await Rpc.fromMap(data).create();
            }
            chainIdTextEditController.value.text = "";
            uriTextEditController.value.text = "";
            nameTextEditController.value.text = "";
            id.value = 0;
            return myResponse.success();
        } on FormatException catch (e) {
            return myResponse.error(message: "Format error");
        } catch (e) {
            return myResponse.error(message: e.toString());
        }
    }

    Future<void> getRpc() async {
        var any = await Rpc.all();
        rpc.value = any;
        update();
    }

    Future<myResponse> deleteRpc(Map map) async {
        var c = Rpc.fromMap(map);
        var count = await c.delete();
        if (count > 0){
            return myResponse.success();
        }
        return myResponse.error(message: "Delete fair,Please try again");
    }

    Future<myResponse> selectRpc(Map map) async {
        final storage = Get.find<StorageService>();
        await storage.box.write("chainId", map["id"]);
        return myResponse.success();
    }

    Future<myResponse> editRpc() async {
        if (nameTextEditController.value.text == "") {
            return myResponse.error(message: "Please set chain name");
        }
        if (uriTextEditController.value.text == "") {
            return myResponse.error(message: "Please set rpc");
        }
        if (chainIdTextEditController.value.text == "") {
            return myResponse.error(message: "Please set ChainID");
        }
        try {
            if (id <= 0){
                return myResponse.error(message: "This rpc not found");
            }
            var cid = int.parse(chainIdTextEditController.value.text);
            var ct = await Rpc.first(
                where: "id = ?", whereArgs: [id.value]);
            if (ct == null) {
                return myResponse.error(message: "This rpc not found");
            } else {
                var data = {
                    "uri": uriTextEditController.value.text,
                    "name": nameTextEditController.value.text,
                    "id" : id.value,
                };
                await Rpc.fromMap(data).save();
            }
            chainIdTextEditController.value.text = "";
            uriTextEditController.value.text = "";
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
