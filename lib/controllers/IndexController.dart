import 'package:contractop/models/Operator.dart';
import 'package:contractop/service/DbService.dart';
import 'package:contractop/service/StorageService.dart';
import 'package:contractop/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

class IndexController extends GetxController {
    final title = "Block Chain Contract Operator";
    final dbService = Get.find<DbService>();
    var operators = [].obs;
    String? secret;

    Future<myResponse> addOperator() async {
        if (secret != null){
            try {
                Credentials fromHex = EthPrivateKey.fromHex(secret as String);
                var publicKey = await fromHex.extractAddress();
                String public_key = publicKey.toString();
                var op = await Operator.first(where:"public_key = ?",whereArgs: [public_key]);
                if (op != null){
                    return myResponse.error(message: "This operator has been exists");
                }else{
                    var data = {
                        "public_key" : public_key,
                        "secret_key" : encrypt(secret as String)
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

    // Future<void> selectOperator(Map map) async {
    //     final storage = Get.find<StorageService>();
    //     await storage.box.write("operatorId", map["id"]);
    //     Get.toNamed("/main");
    // }

    Future<myResponse> selectOperator(Map map) async {
        final storage = Get.find<StorageService>();
        await storage.box.write("operatorId", map["id"]);
        return myResponse.success();
    }

}
