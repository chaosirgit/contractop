import 'package:contractop/models/Operator.dart';
import 'package:contractop/service/DbService.dart';
import 'package:contractop/service/StorageService.dart';
import 'package:contractop/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

class IndexController extends GetxController {
    final title = "Block Chain Contract Operator";
    final dbService = Get.find<DbService>();
    var operators = [].obs;
    final secret = "".obs;
    final name = "".obs;

    Future<myResponse> addOperator() async {
        if (name.value == "") {
            return myResponse.error(message: "Please set your operator name");
        }
        if (secret.value != ""){
            try {
                Credentials fromHex = EthPrivateKey.fromHex(secret.value);
                var publicKey = await fromHex.extractAddress();
                String public_key = publicKey.toString();
                var op = await Operator.first(where:"public_key = ?",whereArgs: [public_key]);
                if (op != null){
                    return myResponse.error(message: "This operator has been exists");
                }else{
                    var data = {
                        "public_key" : public_key,
                        "secret_key" : encrypt(secret.value),
                        "name" : name.value
                    };
                    await Operator.fromMap(data).save();
                }
                return myResponse.success();
            } on FormatException catch(e) {
                return myResponse.error(message: "Secret format error");
            }catch (e) {
                print(e);
                return myResponse.error(message: e.toString());
            }
        }
        return myResponse.error(message: "Please fill your secret");
    }

    Future<void> getOperators() async {
        var any = await Operator.all();
        operators.value = any;
        update();
    }

    Future<myResponse> deleteOperator(Map map) async {
        var op = Operator.fromMap(map);
        var count = await op.delete();
        if (count > 0){
            return myResponse.success();
        }
        return myResponse.error(message: "Delete fair,Please try again");
    }

    Future<myResponse> selectOperator(Map map) async {
        final storage = Get.find<StorageService>();
        await storage.box.write("operatorId", map["id"]);
        return myResponse.success();
    }

}
